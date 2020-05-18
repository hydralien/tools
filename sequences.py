from getopt import getopt
import sys
import re

import argparse

unique_key = ''
parser=argparse.ArgumentParser(
    description="Parser for the text data to extract portions of data.",
    usage='%(prog)s [options]'
)
parser.add_argument('-s',  action="store", dest="start", nargs="+", help="start match, dump starts if found, multiple occurrences allowed")
parser.add_argument('-e',  action="store", dest="end",   nargs="+", help="end match, dump ends if found, multiple occurrences allowed")
parser.add_argument('-p',  action="store", dest="separate", nargs="+", help="optional separator for found cases")
parser.add_argument('-b',  action="store", dest="before", type=int, help="optional number of lines to print before start match")
parser.add_argument('-a',  action="store", dest="after", type=int, help="optional number of lines to print after start match")
parser.add_argument('-f',  dest="force", action='store_true', help="voluntary option to force (allow) empty start and/or end")
parser.add_argument('-r',  dest="regexp", action='store_true', help="optionally treat match as regexps")
parser.add_argument('-u',  dest="unique", action='store_true', help="optionally output unique sequences only (BEWARE or memory usage)")
parser.add_argument('-c',  dest="count", action='store_true', help="optional flag to provide counts of unique sequences match (works with -u only)")

def main(argv):
    args = parser.parse_args()

    force = False
    starts = []
    ends = []
    separator = []
    before = 0
    after = 0
    regexp = False
    unique = False
    count = False

    print(args)

    if args.start: starts.extend(args.start)
    if args.end: ends.extend(args.end)
    if args.separate: separator.extend(args.separate)
    if args.force: force = args.force
    if args.before: before = args.before
    if args.after: after = args.after
    if args.regexp: regexp = args.regexp
    if args.count: count = args.count
    if args.unique: unique = args.unique

    if not starts and not force:
        print("If start clause(s) '-s match' are omitted, output starts right away. Use -f to confirm.")
        sys.exit(1)

    if not ends and not force:
        print("If end clause(s) '-e match' are omitted, output (once starts) goes till the end of input. Use -f to confirm.")
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
