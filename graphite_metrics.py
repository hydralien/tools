import urllib2
import json

metricSearch = 'https://graphite.booking.com/metrics/find/?format=completer&automatic_variants=1&query='
searchClause = "pageview"
roleName = "*hmsapp*"

def getMetrics(path=''):
    result = urllib2.urlopen(metricSearch + path);
    jsonDump = result.read()
    metricList = json.loads(jsonDump)

    return metricList

def collectMetrics(rootPath, searchTerm, pathDepth):
    resultMetrics = []

    for depth in range(0, 15 - pathDepth):
        currentPath = rootPath + ("*." * depth) + searchTerm
        #print "getting metrics for {path}".format(path=currentPath)
        pathMetrics = getMetrics(currentPath)

        if not pathMetrics or not pathMetrics['metrics']:
            #print "Path {} has no data".format(currentPath)
            continue

        for metric in pathMetrics['metrics']:
            metric['depth'] = depth
            resultMetrics.append(metric)

    return resultMetrics


roleMetrics = collectMetrics('', roleName, 0)

for metric in roleMetrics:
    print "{depth}: {path}".format(depth=metric['depth'], path=metric['path'])
    continue
    if metric['is_leaf'] == "1":
        if searchClause in metric['path']:
            print metric['path']
        continue
    roleSearch = collectMetrics(metric['path'], '*{}*'.format(searchClause), metric['depth'])
    for found in roleSearch:
        print found['path']
