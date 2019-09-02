#!/usr/local/bin/perl
#-------------------------------------------------------------------------------
# Copyright IHTSDO 2012
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#       http://www.apache.org/licenses/LICENSE-2.0
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#-------------------------------------------------------------------------------
# This perl script carries no warranty of fitness for any purpose.
# Use at your own risk.
#-------------------------------------------------------------------------------
# This perl script computes the transitive closure of a Directed Acyclic Graph
# input in transitive reduction form.
# Input is in the format of the SNOMED CT relationships table
# Isa relationships are those elements in the table with relationshipID=116680003
#-------------------------------------------------------------------------------

# use this script as
# perl transitiveClosure.pl <relationshipsFileName1> [<relationshipsFileName2> ...] <outputFileName>
# Input files <relationshipsFileName1> (and optionally <relationshipsFileName2> ...) contain the inferred child-parent pairs 
# as distributed in the relationships table, RF2 format SNAPSHOT
# Use multiple input files when combining Extension files with the International Edition

# output is a tab-delimited file with two columns, child - parent.

#-------------------------------------------------------------------------------
# Start MAIN
#-------------------------------------------------------------------------------

%children = ();
%visited = ();
%descendants = (); 

for (my $infile=0; $infile < $#ARGV; $infile++) {
   &readrels(\%children,$infile);
}




$counter=0;
$root="138875005";


transClos($root,\%children,\%descendants,\%visited);

printRels(\%descendants,$#ARGV);


#-------------------------------------------------------------------------------
# END MAIN
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# INPUT
#-------------------------------------------------------------------------------
# Takes as arguments: a hash table reference and an argument number $argn
# Opens the relationships table in the file designated by the name in $ARGV[$argn]
# Reads the isa-s and stores them in the hash 
#-------------------------------------------------------------------------------
sub readrels {
   local($childhashref,$argn) = @_;
   my ($firstline,@values);
   open(ISAS,$ARGV[$argn]) || die "can't open $ARGV[$argn]";
   # read first input row
   chop($firstline = <ISAS>);
   # throw away first row, it contains the column names

   # read remaining input rows
   while (<ISAS>) {
      chop;
      @values=split('\t',$_);
      if (($values[7] eq "116680003") && ($values[2] eq "1")) { # rel.Type is "is-a" 
         $$childhashref{$values[5]}{$values[4]} = 1; # a hash of hashes, where parent is 1st arg and child is 2nd.
      }
   }
   close(ISAS);
}


#-------------------------------------------------------------------------------
# transClos
#-------------------------------------------------------------------------------
# This subroutine is based on a method described in "Transitive Closure Algorithms
# Based on Graph Traversal" by Yannis Ioannidis, Raghu Ramakrishnan, and Linda Winger,
# ACM Transactions on Database Systems, Vol. 18, No. 3, September 1993,
# Pages: 512 - 576.
# It uses a simplified version of their "DAG_DFTC" algorithm.
#-------------------------------------------------------------------------------
# 
sub transClos { # recursively depth-first traverse the graph.
   local($startnode,$children,$descendants,$visited) = @_;
   my($descendant, $childnode);
   $counter++;
   # if (($counter % 1000) eq 0) { print "Visit ", $startnode, " ", $counter, "\n"; }
   for $childnode (keys %{ $$children{$startnode} }) { # for all the children of the startnode
       unless ($$visited{$childnode}) {  # unless it has already been traversed
          &transClos($childnode,$children,$descendants,$visited); # recursively visit the childnode
          $$visited{$childnode}="T"; # and when the recursive visit completes, mark as visited
       } # end unless
       for $descendant (keys %{ $$descendants{$childnode} }) { # for each descendant of childnode
          $$descendants{$startnode}{$descendant} = 1; # mark as a descendant of startnode
       }
       $$descendants{$startnode}{$childnode} = 1; # mark the immediate childnode as a descendant of startnode
   } # end for
} # end sub transClos


#-------------------------------------------------------------------------------
# OUTPUT
#-------------------------------------------------------------------------------

sub printRels {
   local($descendants,$argn)=@_;
   open(OUTF,">$ARGV[$argn]") || die "can't open $ARGV[$argn]";
   for $startnode (keys %$descendants) {
      for $endnode ( keys %{ $$descendants{$startnode} }) {
         print OUTF "$endnode\t$startnode\n";
      }
#      print OUTF "\n";
   }
}


#-------------------------------------------------------------------------------
# END
#-------------------------------------------------------------------------------


