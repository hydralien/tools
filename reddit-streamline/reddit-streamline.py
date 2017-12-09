#!/usr/local/bin/python2.7

import sys
import os
import urllib
import urllib2
import re
import xml.etree.ElementTree as ET

home = os.path.dirname(os.path.realpath(__file__))
sys.path += [home + '/lib/python-packages']

from bottle import request, response, route, run, debug, template

class fakeNode:
    text = ""
    def attrib():
        return {}
    
def parse_xml(filename="", content=""):
    rss_root = None
    if filename:
        rss_tree = ET.parse(filename)
        rss_root = rss_tree.getroot()
    if content:
        rss_root = ET.fromstring(content)

    ns = {'ns' : 'http://www.w3.org/2005/Atom'}

    for entry in rss_root.findall('ns:entry', ns):
        entry_link = fakeNode()
        entry_content = fakeNode()
        for item in entry:
            if 'link' in item.tag:
                entry_link = item
            if 'content' in item.tag:
                entry_content = item

        content_urls=re.findall('href="([^"]+)"', entry_content.text)
        for content_url in content_urls:
            if 'reddit' not in content_url:
                entry_link.set('href', content_url)
                               
    xml_string = ET.tostring( rss_root, encoding="UTF-8" )
    return xml_string.replace("ns0:", "").replace(":ns0", "")

@route('/')
def index(stuff='Amy'):
    return template('Cosy! Try  <a href="drink/{{stuff}}">drinking</a> at {{home}}', stuff=stuff, home=home)

@route('/diredditfile')
def diredditfile():
    response.content_type = 'application/atom+xml; charset=UTF-8'
    return parse_xml(home + "/rss.xml")

@route('/direddit')
def direddit():
    rss_url = request.query.rss_url

    if 'reddit' not in rss_url:
        return "Unsupported RSS"

    clean_url = urllib.unquote(rss_url)
    rss_request = urllib2.Request(clean_url, None, {'User-Agent' : 'I am a strange loop'})
    rss_response = urllib2.urlopen(rss_request)
    rss_xml = rss_response.read()

    response.content_type = 'application/atom+xml; charset=UTF-8'
    
    return parse_xml(content=rss_xml)
    

@route('/drink/:name')
def drink(name='Alice'):
    return template('<b>Drink me {{name}}</b>! Aww...', name=name)

@route('/reqdump')
def reqdump():
    data = "<html><body><pre>\n"
    for header in request.headers:
        data += "{}:{}<br/>\n".format(header, request.headers.get(header))
    data += "</pre></body></html>"

    return data

debug(True)
if sys.stdin.isatty():
    run(host='localhost', reloader=True, port=8080)
else:
    run(server='cgi')

