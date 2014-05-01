from django.utils.safestring import mark_safe

from eulexistdb.manager import Manager
from eulexistdb.models import XmlModel
from eulxml.xmlmap.core import XmlObject
from eulxml.xmlmap.dc import DublinCore
from eulxml.xmlmap.fields import StringField, NodeField, StringListField, NodeListField
from eulxml.xmlmap.teimap import Tei, TeiDiv, TEI_NAMESPACE

class Bibliography(XmlObject):
    ROOT_NAMESPACES = {'tei' : TEI_NAMESPACE}
    # TODO: handle repeating elements
    title = StringField('tei:title')
    author = StringField('tei:author')
    editor = StringField('tei:editor')
    publisher = StringField('tei:publisher')
    pubplace = StringField('tei:pubPlace')
    date = StringField('tei:date')

    def formatted_citation(self):
        """Generate an HTML formatted citation."""
        cit = {
            "author": '',
            "editor": '',
            "title": self.title,
            "pubplace": self.pubplace,
            "publisher":  self.publisher,
            "date": self.date
        }
        if self.author:
            cit['author'] = '%s. ' % self.author
        if self.editor:
            cit['editor'] = '%s, ed. ' % self.editor

        return mark_safe('%(author)s%(editor)s<i>%(title)s</i>. %(pubplace)s: %(publisher)s, %(date)s.' \
                % cit)


class SourceDescription(XmlObject):
    'XmlObject for TEI Source Description (sourceDesc element).'
    ROOT_NAMESPACES = {'tei' : TEI_NAMESPACE}
    bibl = NodeField('tei:bibl', Bibliography)
    ':class:`Bibliography` - `@bibl`'

    def citation(self):
        'Shortcut for :meth:`Bibligraphy.formatted_citation` to render source bibl'
        return self.bibl.formatted_citation()

class DocTitle(XmlModel, Tei):
    ROOT_NAMESPACES = {'tei' : TEI_NAMESPACE}
    objects = Manager('/tei:TEI')
    text = StringField('tei:text')
    date =  StringField('tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:date')
    author =  StringField('tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:name/tei:choice/tei:sic')

    site_url = 'http://beck.library.emory.edu/oxfordexperience'
    project_desc = StringField('tei:teiHeader/tei:encodingDesc/tei:projectDesc')
    geo_coverage = StringField('tei:teiHeader/tei:profileDesc/tei:creation/tei:rs[@type="geography"]')
    creation_date = StringField('tei:teiHeader/tei:profileDesc/tei:creation/tei:date')
    lcsh_subjects = StringListField('tei:teiHeader//tei:keywords[@scheme="#lcsh"]/tei:list/tei:item')
    identifier_ark = StringField('tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type="ark"]')
    source = StringField('tei:teiHeader/tei:fileDesc/tei:sourceDesc')

    def dc_fields(self):
        dc = DublinCore()
        dc.title = self.title
        dc.creator_list.extend([n.reg for n in self.header.author_list])
        dc.contributor_list.extend([n.reg for n in self.header.editor_list])
        dc.publisher = self.header.publisher
        dc.date = self.header.publication_date
        dc.rights = self.header.availability
        dc.source = self.header.source_description
        dc.subject_list.extend(self.lcsh_subjects)
        dc.description = self.project_desc
        dc.identifier = self.identifier_ark


        if self.geo_coverage:
            dc.coverage_list.append(self.geo_coverage)
        if self.creation_date:
            dc.coverage_list.append(self.creation_date)

        if self.header.series_statement:
            dc.relation_list.append(self.header.series_statement)
        # FIXME: should we also include url? site name & url are currently
        # hard-coded when setting dc:relation in postcard ingest

        return dc

class Doc(XmlModel, TeiDiv):
    ROOT_NAMESPACES = {'tei' : TEI_NAMESPACE}
    doc_author =  NodeField('tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:sic', "self")
    doc = NodeField("tei:div[@type='doc']", "self")
    
    # reference to book for access to document-level information
    doc = NodeField('ancestor::tei:TEI', DocTitle)

    objects = Manager("//tei:TEI")
    # NOTE: this object could be restricted to poems only using [@type='poem']
    # However, it is currently used to retrieve non-poem items, e.g. essays
    # such as "Swan Song" in Eaton.  This should probably be re-thought; at the
    # very least, we may want to rename the model so it is more accurate.

class DocSearch(Doc):
   objects = Manager("//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:name/tei:choice/tei:reg")
