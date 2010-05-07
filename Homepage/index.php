<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de">
<head>
<title>Lab::VISA - measurement control in Perl</title>
<link rel="stylesheet" type="text/css" href="doku.css" />
</head>
<body>
<h1>Lab::VISA</h1>

<div id="camelgraph"><img src="dokutitle.png" width="300px"
    alt="Lab::VISA camelgraph" /></div>
<p>Lab::VISA allows to perform test and measurement tasks with Perl
scripts. It provides an interface to National Instruments' <a
    href="http://sine.ni.com/psp/app/doc/p/id/psp-411">NI-VISA
library</a>, making the standard VISA calls available to Perl programs.
Dedicated instrument driver classes relieve the user from taking care
for internal details and make data aquisition as easy as</p>

<pre class="titleclaim">$voltage = $multimeter-&gt;read_voltage();</pre>

<p>The Lab::VISA software stack comprises three parts that are built
on top of each other and provide increasing comfort. Measurement scripts
can be based on any of these stages.</p>

<p>The lowest level is Lab::VISA. It makes the NI-VISA library
accessible from Perl and thus allows to make any standard VISA call.</p>

<p>The modules in the Lab::Instrument package make communication
with instruments easier by silently handling the protocol overhead.</p>

<p>Package Lab::Tools is the highest abstraction layer and is
intended to support writing better measurement scripts. The modules in
this package offer means to log and plot data and its related meta
information.</p>

<p>These packages together are referred to as the Lab::VISA system.
Encapsulating the complexity of VISA calls into a straightforward to use
library, the Lab::VISA system is designed to make data aquisition fun.</p>

<h2>How to obtain</h2>
<p>The packages are free software and can be downloaded from CPAN.
Follow these links for</p>
<ul>
    <li><a href="http://search.cpan.org/dist/Lab-VISA/">Lab::VISA</a>,</li>
    <li><a href="http://search.cpan.org/dist/Lab-Instrument/">Lab::Instrument</a>,
    and</li>
    <li><a href="http://search.cpan.org/dist/Lab-Tools/">Lab::Tools</a>.</li>
</ul>

<h2>Documentation</h2>
<p>Quite some <a href="docs/">documentation of Lab::VISA</a>
(<a href="docs/documentation.pdf">PDF format</a>) is available. This
documentation includes a <a href="docs/Tutorial.html">tutorial on
using Lab::VISA</a>. Detailed <a href="docs/installation.html">installation
instructions</a> are provided as well.</p>

<p>These <a href="Lab-VISA-talk.pdf">presentation slides on
Lab::VISA</a> introduce the system and discuss a number of <a
    href="http://cpansearch.perl.org/src/SCHROEER/Lab-VISA-2.05/Tutorial/Talk">examples</a>,
which are contained in the Lab::VISA package.</p>

<p>There is a <a
    href="https://www-mailman.uni-regensburg.de/mailman/listinfo/lab-visa-users">mailing
list (lab-visa-users)</a> set up for Lab::VISA. This mailing list is the
right place to give feedback and ask for help.</p>

<p><a href="http://sine.ni.com/psp/app/doc/p/id/psp-411">National
Instruments</a> offers excellent documentation. We especially recommend the
<a href="http://www.ni.com/pdf/manuals/370423a.pdf">NI-VISA User
Manual</a>, the <a href="http://www.ni.com/pdf/manuals/370132c.pdf">NI-VISA
Programmer Reference Manual</a> and these references of <a
    href="http://zone.ni.com/reference/en-XX/help/371361B-01/lvinstio/visa_resource_name_generic/">VISA
resource names</a> and <a
    href="http://zone.ni.com/reference/en-XX/help/371361B-01/lverror/visa_error_codes/">VISA
error codes</a>.</p>

<h2>Status</h2>
<p>Although this software has been used for years in real world
measurements by its developers, it remains work in progress. Please bear
with us while we constantly improve code and documentation.</p>

<p>Lab::VISA is currently developed and employed at <a
    href="http://www.nano.physik.uni-muenchen.de/">nanophysics
group, LMU M&uuml;nchen</a> and <a
    href="http://www.physik.uni-regensburg.de/forschung/strunk/">mesoscopic
physics group, Uni Regensburg</a>. Users have reported further applications
in academic and industrial r&amp;d environments.</p>

<h2>Authors</h2>
<p>The Lab::VISA system was originally developed by <a
    href="http://search.cpan.org/~schroeer/">Daniel Schr&ouml;er</a> and
is now continued by <a href="http://www.akhuettel.de/">Andreas K.
H&uuml;ttel</a>, Daniela Taubert, and Daniel Schr&ouml;er. Most of the documentation was
written by Daniel Schr&ouml;er.</p>

<!-- Start of StatCounter Code -->
<script type="text/javascript">
var sc_project=5798171; 
var sc_invisible=1; 
var sc_security="385de927"; 
</script>

<script type="text/javascript"
    src="http://www.statcounter.com/counter/counter.js"></script>
<noscript>
<div class="statcounter"><a title="free hit counter"
    href="http://www.statcounter.com/" target="_blank"><img
    class="statcounter"
    src="http://c.statcounter.com/5798171/0/385de927/1/"
    alt="free hit counter"></a></div>
</noscript>
<!-- End of StatCounter Code -->


</body>
</html>