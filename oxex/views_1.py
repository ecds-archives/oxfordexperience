import os
from urllib import urlencode

from django.conf import settings
from django.shortcuts import render
from django.http import HttpResponse, Http404
from django.core.paginator import Paginator, InvalidPage, EmptyPage, PageNotAnInteger
from django.template import RequestContext
from django.shortcuts import redirect

from oxfordexperience.models import DocTitle, Doc, Bibliography, SourceDescription, DocSearch
from oxfordexperience.forms import DocSearchForm

from eulcommon.djangoextras.http.decorators import content_negotiation
from eulexistdb.query import escape_string
from eulexistdb.exceptions import DoesNotExist
 
def docs(request):
  docs =DocTitle.objects.only('id', 'title', 'date', 'author').order_by('date')
  number_of_results = 26
  
  paginator = Paginator(list(docs), number_of_results)
  page = request.GET.get('page')
  try:
    docs = paginator.page(page)
  except PageNotAnInteger:
    docs = paginator.page(1)
  except EmptyPage:
    docs = paginator.page(paginator.num_pages)
  return render(request, 'docs.html', {'docs' : docs})
#context_instance=RequestContext(request)

def doc_display(request, doc_id):
    "Display the contents of a single document."
    try:
        doc = DocTitle.objects.get(id__exact=doc_id)
        format = doc.xsl_transform(filename=os.path.join(settings.BASE_DIR, 'xslt', 'form.xsl'))
        return render(request, 'doc_display.html', {'doc': doc, 'format': format.serialize()}
      )
    except DoesNotExist:
        raise Http404

def doc_xml(request, doc_id):
  "Display the original TEI XML for a single document."
  try:
    doc = DocTitle.objects.get(id__exact=doc_id)
    xml_tei = doc.serialize(pretty=True)
    #return render(request, 'doc_xml.html', {'doc':doc, 'xml_tei':xml_tei}, content_type="tei+xml")
    return render(request, 'doc_xml.html', {'doc':doc})
  except DoesNotExist:
    raise Http404

def doc_down(request, doc_id):
  "Download the original TEI XML for a single document."
  try:
    doc = DocTitle.objects.get(id__exact=doc_id)
    xml_tei = doc.serialize(pretty=True)
    return HttpResponse(xml_tei, mimetype='application/tei+xml')
  except DoesNotExist:
    raise Http404
    
def overview(request):
   "About the Oxford Experience."
   return render(request, 'overview.html')
 
def searchbox(request):
    "Search documents by keyword/title/author/date"
    form = DocSearchForm(request.GET)
    response_code = None
    search_opts = {}
    all_docs = None
    number_of_results = 10
    
    if form.is_valid():
        if 'title' in form.cleaned_data and form.cleaned_data['title']:
            search_opts['title_list__fulltext_terms'] = '%s' % form.cleaned_data['title']
        if 'author' in form.cleaned_data and form.cleaned_data['author']:
            search_opts['Doc.doc_author__fulltext_terms'] = '%s' % form.cleaned_data['author']
        if 'keyword' in form.cleaned_data and form.cleaned_data['keyword']:
            search_opts['fulltext_terms'] = '%s' % form.cleaned_data['keyword']
        if 'date' in form.cleaned_data and form.cleaned_data['date']:
            search_opts['fulltext_terms'] = '%s' % form.cleaned_data['date']

        #docs = DocSearch.objects.only(id__exact=doc_id).filter(**search_opts)
        docs = Doc.objects.only("doc__title","doc__id","title", "id").filter(**search_opts)
        if 'keyword' in form.cleaned_data and form.cleaned_data['keyword']:
            docs = docs.only_raw(line_matches='%%(xq_var)s//tei:l[ft:query(., "%s")]' \
                                    % escape_string(form.cleaned_data['keyword']))
        all_docs = docs.all()
        searchbox_paginator = Paginator(all_docs, number_of_results)
        try:
            page = int(request.GET.get('page', '1'))
        except ValueError:
            page = 1
        # If page request (9999) is out of range, deliver last page of results.
        try:
            searchbox_page = searchbox_paginator.page(page)
        except (EmptyPage, InvalidPage):
            searchbox_page = searchbox_paginator.page(paginator.num_pages)
           
        response = render(request, 'search.html', {
                "searchbox": form,
                "all_docs_paginated": searchbox_page,
                "keyword": form.cleaned_data['keyword'],
                "title": form.cleaned_data['title'],
                "author": form.cleaned_data['author'],
                "date": form.cleaned_data['date'],
        },
        context_instance=RequestContext(request))
    #no search conducted yet, default form
    else:
        response = render(request, 'search.html', {
                    "searchbox": form
            })
       
    if response_code is not None:
        response.status_code = response_code
    return response


docs.html:
{% extends "base.html" %}

{% block title %}<h2>Oxford Experience Documents</h2>{% endblock %}

{% block content %}
{% if docs %}
    <ul class="document">
    {% for doc in docs %}
        <li>
      {% if doc.id %}
        <a href="{% url doc_display doc.id %}">{{ doc.title }}</a>, {{doc.author}}
      {% else %} 
        {{ doc.title }}, {{doc.author}}
      {% endif %}
        </li>
    {% endfor %}
   </ul>
{% else %}
    <p>Nothing found.</p>
{% endif %}
