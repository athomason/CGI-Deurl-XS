use ExtUtils::MakeMaker;
$Verbose = 1;
WriteMakefile(
    NAME   => 'CGI::Deurl::XS::parser',
    SKIP   => [qw(all static dynamic )],
    clean  => {'FILES' => 'libparser$(LIB_EXT)'},
);


sub MY::top_targets {
'
all :: static

pure_all :: static

static ::       libparser$(LIB_EXT)

libparser$(LIB_EXT): $(O_FILES)
	$(AR) cr libparser$(LIB_EXT) $(O_FILES)
	$(RANLIB) libparser$(LIB_EXT)

'.($ExtUtils::MakeMaker::VERSION >= 7.16?'

dynamic ::
	$(NOECHO) $(NOOP)
':''); #https://rt.cpan.org/Ticket/Display.html?id=117800
}
