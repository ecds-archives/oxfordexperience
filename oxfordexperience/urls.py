from django.conf.urls import patterns, include, url
from django.conf.urls.defaults import *
from django.conf import settings
from django.conf.urls.static import static
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
#from django.views.generic.simple import redirect_to

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

from oxex.views import docs, doc_display, doc_xml, overview, searchbox

urlpatterns = patterns('oxex.views',
  url(r'^$', 'docs', name='docs'),
  url(r'^search/$', 'searchbox', name='search'),
  url(r'^overview/$', 'overview', name='overview'),
  url(r'^(?P<doc_id>[^/]+)/$', 'doc_display', name="doc_display"),
  url(r'^(?P<doc_id>[^/]+)/view=xml$', 'doc_xml', name="doc_xml"),
  url(r'^(?P<doc_id>[^/]+)/download$', 'doc_down', name="doc_down"),
)

if settings.DEBUG:
  urlpatterns += patterns(
    url(r'^static/(?P<path>.*)$', 'django.views.static.serve', {'document_root': settings.STATIC_ROOT } ),
)


    #Uncomment the admin/doc line below to enable admin documentation:
    #url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    #url(r'^admin/', include(admin.site.urls)),
    #)
    
