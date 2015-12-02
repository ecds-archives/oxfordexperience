from django.conf.urls import patterns, include, url
from django.conf import settings

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

from oxex.views import docs, doc_display, doc_xml, overview, searchbox

urlpatterns = patterns('oxex.views',
  url(r'^$', 'overview', name='overview'),
  url(r'^search/$', 'searchbox', name='search'),
  url(r'^browse/$', 'docs', name='docs'),
  url(r'^(?P<doc_id>[^/]+)/$', 'doc_display', name="doc_display"),
  url(r'^(?P<doc_id>[^/]+)/view=xml$', 'doc_xml', name="doc_xml"),
  url(r'^(?P<doc_id>[^/]+)/download$', 'doc_down', name="doc_down"),
)

if settings.DEBUG:
  urlpatterns += patterns(
    url(r'^static/(?P<path>.*)$', 'django.views.static.serve', {'document_root': settings.STATIC_ROOT } ),
)  
