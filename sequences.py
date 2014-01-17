from getopt import getopt
import sys
import re

# Params:
# -s <match> - start match, dump starts if found, multiple occurrences allowed.
# -e <match> - end match, dump ends if found, multiple occurrences allowed.
# -f - voluntary option to force (allow) empty start and/or end 
# -p - optional separator for found cases
# -b <n> - optional number of lines to print before start match
# -a <n> - optional number of lines to print after end match
# -r - optionally treat match as regexps
# -u - optionally output unique sequences only (BEWARE or memory usage)
# -c - optional flag to provide counts of unique sequences match (works with -u only)

unique_key = '' 

def main(argv):
    opts, args = getopt(argv, 's:e:fs:b:a:p:ruc')
    force = []
    starts = []
    ends = []
    separator = []
    before = []
    after = []
    regexp = []
    unique = []
    count = []
    for (param, param_value) in opts:
        {
            '-s' : lambda val: starts.append(val),
            '-e' : lambda val: ends.append(val),
            '-f' : lambda val: force.append(True),
            '-p' : lambda val: separator.append(val),
            '-b' : lambda val: before.append(val),
            '-a' : lambda val: after.append(val),
            '-r' : lambda val: regexp.append(True),
            '-u' : lambda val: unique.append(True),
            '-c' : lambda val: count.append(True),
        }.get(param)(param_value)
    before = int(before.pop()) if before else 0
    after = int(after.pop()) if after else 0

    if not starts and not force:
        print "If start clause(s) '-s match' are omitted, output starts right away. Use -f to confirm."
        sys.exit(1)

    if not ends and not force:
        print "If end clause(s) '-e match' are omitted, output (once starts) goes till the end of input. Use -f to confirm."
        sys.exit(1)

    before_lines = []
    after_lines = 0
    unique_seqs = {}
    def output(line, end_of_sequence=False):
        if unique:
            global unique_key
            unique_key += line
            if end_of_sequence:
                unique_seqs[unique_key] = unique_seqs.get(unique_key, 0) + 1
                unique_key = ''
            return
        sys.stdout.write(line)

    dump_enabled = False
    if not starts:
        dump_enabled = True
        after_lines = after

    for line in sys.stdin.readlines():
        if dump_enabled:
            output(line)
            if ends:
                for match in ends:
                    if (not regexp and match in line) or (regexp and re.search(match, line)):
                        dump_enabled = False
                        after_lines = after
                        if separator:
                            output('\n'.join(separator) + '\n')
                        if not after_lines:
                            output('', True)
                        break
        else:
            if after_lines:
                after_lines -= 1
                output(line, not after_lines)
            for match in starts:
                if (not regexp and match in line) or (regexp and re.search(match, line)):
                    dump_enabled = True
                    if after_lines:
                        output('', True)
                    while before_lines:
                        output(before_lines.pop(0))
                    output(line)
                    break
            if not dump_enabled and before:
                before_lines.append(line)
                if len(before_lines) > before:
                    before_lines.pop(0)

    if unique_key: 
        output('', True)

    if unique:
        unique = []
        for line in unique_seqs.keys():
            if count:
                line = "{cnt} ENTRIES:\n{data}".format(cnt=unique_seqs[line], data=line)
            output(line)
                

if __name__ == '__main__':
    main(sys.argv[1:])
