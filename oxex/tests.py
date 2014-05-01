"""
Oxford Experience Test Cases
"""

from os import path

from django.core.urlresolvers import reverse
from django.test import TestCase
from django.conf import settings

from eulxml import xmlmap

from oxex.models import DocTitle, Doc, Bibliography, SourceDescription, DocSearch
from oxex.forms import DocSearchForm

exist_fixture_path = path.join(path.dirname(path.abspath(__file__)), 'fixtures')
exist_index_path = path.join(path.dirname(path.abspath(__file__)), '..', 'exist_index.xconf')

class TestDocTitle(DocTitle):
    doc = xmlmap.NodeListField('//tei:div[@type="doc"]', Doc)


class OxExTestCase(TestCase):
    FIXTURES = ['Allen_Bio.xml', 'allen.xml', 'Allen11-CandlerLetter.xml']
    
    def setUp(self):
        #load the three xml doc objects
        self.docs = dict()
        for file in self.FIXTURES:
            filebase = file.split('.')[0]
            self.docs[filebase] = xmlmap.load_xmlobject_from_file(path.join(exist_fixture_path, file), TestDocTitle)
    
    def test_init(self):
        for file, p in self.docs.iteritems():
            self.assert_(isinstance(p, DocTitle))

    def test_xml_fixture_load(self):
        self.assertEqual(3, len(self.docs))

    def test_doc_model(self):
        self.assertEqual('K. T. Tsoong Letter, Jan 6, 1909, an electronic edition', self.docs['allen'].title)
        self.assertEqual('allen.001', self.docs['allen'].id)

    def test_dublin_core(self):
        dc = self.docs['Allen11-CandlerLetter'].dublin_core
        self.assert_(isinstance(dc, xmlmap.dc.DublinCore))
        self.assertEqual('Letter to Young John Allen, February 6, 1892, an electronic edition', dc.title, 'document title should be in dc:title')
        self.assertEqual('Candler, Warren A. (Warren Akin), 1857-1941', dc.creator)
        self.assertFalse(dc.contributor_list, 'dc:contributor should not be set TEI has no document author')
        self.assertEqual('Emory University, Lewis H. Beck Center', dc.publisher, 'publisher from teiHeader should be set in dc:publisher')
        self.assertEqual('2007', dc.date, 'publication date from teiHeader should be set in dc:date')
        self.assert_('Emory University makes a claim of copyright' in dc.rights, 'availability statement in dc:rights')
        self.assert_('Letter from Warren Akin Candler to Young John Allen' in dc.source, 'source title should be listed in dc:source')
        self.assert_('Young John Allen Papers, Manuscript, Archive, and Rare Book Library, Emory University' in dc.source)
        self.assert_('February 6, 1892' in dc.source, 'source publication date should be listed in dc:source')
        self.assert_('Candler, Warren Akin, 1857-1941.' in dc.subject_list)
        self.assert_('Allen, Young John, 1836-1907.' in dc.subject_list)
        self.assert_('Missionaries--American--1880-1900.' in dc.subject_list)      
        self.assert_('text was created by the Lewis H. Beck Center' in dc.description, 'encoding/project description should be in dc:description')
        self.assert_('United States' in dc.coverage_list, 'creation/rs[@type="geography"] should be in dc:coverage')
        self.assert_('1800-1899' in dc.coverage_list, 'creation/date should be in dc:coverage')
        self.assert_('The Oxford Experience' in dc.relation, 'teiHeader seriesStmt should be in dc:relation')

class OxExViewTestCase(TestCase):
    # tests for ONLY those views that do NOT require eXist full-text index
    exist_fixtures = {'directory' : exist_fixture_path }

    def test_docs(self):
        # oxfordexperience docs should list all documents
        docs_url = reverse('docs')
        response = self.client.get(docs_url)
        expected = 200
        self.assertEqual(response.status_code, expected,
                        'Expected %s but returned %s for %s' % \
                        (expected, response.status_code, docs_url))
        #self.assertEqual('response', response.content)
        # should contain title, date, author, link for each fixture
        self.assertContains(response, 'Letter to Young John Allen',
            msg_prefix='includes title of "Letter to Young John Allen"')
        self.assertContains(response, 'February 6, 1892',
            msg_prefix='includes date of "Letter to Young John Allen"')
        self.assertContains(response, 'Warren Akin Candler',
            msg_prefix='includes author of "Letter to Young John Allen"')
        self.assertContains(response, reverse('doc_display', args=['oeAllen11-CandlerLetter']),
            msg_prefix='includes link to "Letter to Young John Allen"')
        self.assertContains(response, 'K. T. Tsoong Letter',
            msg_prefix='includes title of "K. T. Tsoong Letter"')
        self.assertContains(response, 'Jan 6, 1909',
            msg_prefix='includes date of "K. T. Tsoong Letter"')
        self.assertContains(response, 'K. T. Tsoong',
            msg_prefix='includes author of "K. T. Tsoong Letter"')
        self.assertContains(response, reverse('doc_display', args=['allen.001']),
            msg_prefix='includes link to "K. T. Tsoong Letter"')
        self.assertContains(response, 'Biography of Young J. Allen',
            msg_prefix='includes title of "Biography of Young J. Allen"')
        self.assertContains(response, 'date unknown',
            msg_prefix='includes date of "Biography of Young J. Allen"')
        self.assertContains(response, 'Charles Jarrell',
            msg_prefix='includes author of "Biography of Young J. Allen"')
        self.assertContains(response, reverse('doc_display', args=['oeAllenBio']),
            msg_prefix='includes link to "Biography of Young J. Allen"')

    def test_doc_display(self):
        # doc_display should display the content of the document
        doc_display_url = reverse('doc_display', args=['allen.001'])
        response = self.client.get(doc_display_url)
        expected = 200
        self.assertEqual(response.status_code, expected,
                         'Expected %s but returned %s for %s' % \
                        (expected, response.status_code, doc_display_url))
        self.assertContains(response, 'K. T. Tsoong Letter',
            msg_prefix='response should contain document title')
        self.assertContains(response, 'K. T. Tsoong',
            msg_prefix='response should contain author')
        self.assertContains(response, 'because this was the first letter I received from China since I left there',
            msg_prefix='response should contain text')
        self.assertContains(response, 'Arithmetic (1st Sub)',
            msg_prefix='response should contain text')
        self.assertContains(response, 'a card written on to Mr. Bell from Mrs. Candler.',
            msg_prefix='response should contain text')

        # not found
        doc_display_url = reverse('doc_display', args=['nonexistent'])
        response = self.client.get(doc_display_url)
        expected = 404
        self.assertEqual(response.status_code, expected,
                        'Expected %s but returned %s for %s' % \
                        (expected, response.status_code, doc_display_url))

    def test_overview(self):
        overview_url = reverse('overview')
        response = self.client.get(overview_url)
        expected = 200
        self.assertEqual(response.status_code, expected,
                         'Expected %s but returned %s for %s' % \
                        (expected, response.status_code, overview_url))

    def test_doc_xml(self):
        # expose TEI xml for a document
        doc_xml_url = reverse('doc_xml', args=['oeAllenBio'])
        response = self.client.get(doc_xml_url)
        expected = 200
        self.assertEqual(response.status_code, expected,
                         'Expected %s but returned %s for %s' % \
                        (expected, response.status_code, doc_xml_url))
        self.assertContains(response, '<TEI')

        # xml request for non-existent document should return 404
        doc_xml_url = reverse('doc_xml', args=['nonexistent'])
        response = self.client.get(doc_xml_url)
        expected = 404
        self.assertEqual(response.status_code, expected,
                         'Expected %s but returned %s for %s' % \
                        (expected, response.status_code, doc_xml_url))

    def test_doc_down(self):
        # expose TEI xml for a document
        doc_down_url = reverse('doc_down', args=['oeAllenBio'])
        response = self.client.get(doc_down_url)
        expected = 200
        self.assertEqual(response.status_code, expected,
                         'Expected %s but returned %s for %s' % \
                        (expected, response.status_code, doc_down_url))
        self.assertEqual('application/tei+xml', response['Content-Type'])
        self.assertContains(response, '<TEI')

        # xml request for non-existent document should return 404
        doc_down_url = reverse('doc_xml', args=['nonexistent'])
        response = self.client.get(doc_down_url)
        expected = 404
        self.assertEqual(response.status_code, expected,
                         'Expected %s but returned %s for %s' % \
                        (expected, response.status_code, doc_down_url))

class FullTextOxExViewsTest(TestCase):
    # tests for views that require eXist full-text index
    exist_fixtures = {'index': exist_index_path, 'directory': exist_fixture_path}

    def test_search_keyword(self):
        search_url = reverse('search')
        response = self.client.get(search_url, {'keyword': 'china'})
        expected = 200
        self.assertEqual(response.status_code, expected,
                        'Expected %s but returned %s for %s' % \
                        (expected, response.status_code, search_url))
        
        self.assertContains(response, reverse('doc_display', kwargs={'doc_id':'oeAllen11-CandlerLetter'}),
            msg_prefix='search results include link to document with match')
        self.assertContains(response, 'Letter to Young John Allen',
            msg_prefix='search results include title of document with match')
        self.assertContains(response, 'Warren Akin Candler',
            msg_prefix='search results include author of document with match')
        self.assertContains(response, '1892-02-06',
            msg_prefix='search results include date of document with match')

    def test_search_title(self):
        search_url = reverse('search')
        response = self.client.get(search_url, {'title': 'Tsoong'})
        expected = 200
        self.assertEqual(response.status_code, expected,
                        'Expected %s but returned %s for %s' % \
                        (expected, response.status_code, search_url))
        # should include link to allen.001
        self.assertContains(response, reverse('doc_display', kwargs={'doc_id':'allen.001'}),
            msg_prefix='search results include link to document with match')
        self.assertContains(response, 'K. T. Tsoong Letter',
            msg_prefix='search results include title of document with match')
        self.assertContains(response, 'K. T. Tsoong',
            msg_prefix='search results include author of document with match')
        self.assertContains(response, '1909-01-06',
            msg_prefix='search results include date of document with match')

    def test_search_author(self):
        search_url = reverse('search')
        response = self.client.get(search_url, {"author" : "Dickey"})
        expected = 200
        self.assertEqual(response.status_code, expected,
                        'Expected %s but returned %s for %s' % \
                        (expected, response.status_code, search_url))       
        self.assertContains(response, reverse('doc_display', kwargs={'doc_id':'oeReeve863-DickeyLetter.01'}),
            msg_prefix='search results include link to document with match)')
        self.assertContains(response, 'Letter from President James E. Dickey to Thomas Ellis Reeve',
            msg_prefix='search results include title of document with match')
        self.assertContains(response, 'James E. Dickey',
            msg_prefix='search results include author of document with match')
        self.assertContains(response, '1908-08-29',
            msg_prefix='search results include date of document with match')

    def test_search_date(self):
        search_url = reverse('search')
        response = self.client.get(search_url, {"date" : "1908"})
        expected = 200
        self.assertEqual(response.status_code, expected,
                        'Expected %s but returned %s for %s' % \
                        (expected, response.status_code, search_url))       
        self.assertContains(response, reverse('doc_display', kwargs={'doc_id':'oeBryanLetter1908-11-15.01'}),
            msg_prefix='search results include link to document with match)')
        self.assertContains(response, 'Letter from W. Lyle Bryan to his mother',
            msg_prefix='search results include title of document with match')
        self.assertContains(response, 'W. Lyle Bryan',
            msg_prefix='search results include author of document with match')
        self.assertContains(response, '1908-11-15',
            msg_prefix='search results include date of document with match')
        

 
