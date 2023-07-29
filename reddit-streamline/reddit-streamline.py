#!/usr/local/bin/python3

import sys
import os
import urllib
import urllib.request
import re
import xml.etree.ElementTree as ET
import logging

logger = logging.getLogger('rss_application')
logger.setLevel(logging.DEBUG)

fh = logging.FileHandler('rss.log')
fh.setLevel(logging.DEBUG)
logger.addHandler(fh)

home = os.path.dirname(os.path.realpath(__file__))
sys.path += [home + '/lib/python-packages']

from bottle import request, response, route, run, debug, template

class fakeNode:
    text = ""
    def attrib():
        return {}
    def set(self, var, val):
        return True

def hop_by_hop_headers():
    return {
        'connection' : 1,
        'keep-alive' : 1,
        'proxy-authenticate' : 1,
        'proxy-authorization' : 1,
        'te' : 1,
        'trailers' : 1,
        'transfer-encoding' : 1,
        'upgrade' : 1
    }
    
def parse_xml(filename="", content=""):
    rss_root = None
    if filename:
        rss_tree = ET.parse(filename)
        rss_root = rss_tree.getroot()
    if content:
        rss_root = ET.fromstring(content)

    ns = {'ns' : 'http://www.w3.org/2005/Atom'}

    self_links = rss_root.findall('ns:link', ns)
    for self_link in self_links:
        if 'rel' not in self_link.attrib or self_link.attrib['rel'] != 'self':
            continue
        self_link.set("href", request.url)
    
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
                               
    xml_string = ET.tostring( rss_root, encoding="UTF-8" ).decode().replace("ns0:", "").replace(":ns0", "")
    return xml_string

@route('/')
def index():
    return 'Try adding "direddit/" + Reddit feed path to the URL, e.g.  <a href="direddit/r/programming/.rss">/direddit/r/programming/.rss</a>'

@route('/direddit/<rss_path:path>')
def direddit(rss_path=""):
    rss_url = "https://reddit.com/" + rss_path

    clean_url = urllib.parse.unquote(rss_url)
    rss_request = urllib.request.Request(clean_url, None, {'User-Agent' : 'I am a strange loop'})
    rss_response = urllib.request.urlopen(rss_request)
    rss_xml = rss_response.read()

    hop_headers = hop_by_hop_headers()
    rss_headers = rss_response.info()
    for header_name in rss_headers:
        if header_name.lower() in hop_headers:
            continue
        response.set_header(header_name, rss_headers[ header_name ])

    response.content_type = 'application/atom+xml; charset=UTF-8'
    
    rss_converted_xml = parse_xml(content=rss_xml)

    response.set_header("Content-Length", len(rss_converted_xml))

    return rss_converted_xml.encode()

def log_request():
    headers = ""
    for header in request.headers:
        hvalue = request.headers.get(header)
        headers += header + ": " + hvalue + "; "
    log_line = request.path + " -> " + request.query_string + " / " + headers
    logger.info(log_line)


if sys.stdin.isatty():
    debug(True)
    try:
        run(reloader=True)
    except (KeyboardInterrupt, SystemExit):
        sys.stderr.close()
        quit()
else:
    run(server='cgi')

