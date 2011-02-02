# Build.PL
use strict; use warnings;
use Module::Build;

my $build = Module::Build->new(
	# look up Module::Build::API for the info!
	'dynamic_config'	=> 0,
	'module_name'		=> 'POE::Component::SpreadClient',
	'license'		=> 'perl',

	'dist_abstract'		=> "Handle Spread communications in POE",
	'dist_author'		=> 'Apocalypse <APOCAL@cpan.org>',

	'create_packlist'	=> 1,
	'create_makefile_pl'	=> 'traditional',
	'create_readme'		=> 1,

	'test_files'		=> 't/*.t',

	'requires'		=> {
		# POE Stuff
		'POE'				=> 0,
		'POE::Session::AttributeBased'	=> 0,

		# FIXME POE stuff that Test::Dependencies needs to see
		'POE::Session'			=> 0,
		'POE::Wheel::ReadWrite'		=> 0,

		# Spread itself!
		'Spread'			=> '3.017',

		# minimum perl version
		'perl'				=> '5.006',

		'constant'			=> 0,
	},
);

# all done!
$build->create_build_script;
