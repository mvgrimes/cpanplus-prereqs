use Module::Build;
my $build = Module::Build->new(
    module_name             => 'CPANPLUS::Shell::Default::Plugins::Prereqs',
    license                 => 'perl',
    create_readme           =>  1,
    requires                => {
            'CPANPLUS'              => '0.77',
        },
    build_requires          => {        
            'Test::More'            => 0,
            'File::Spec'            => 0,
            'Module::Build'         => '0.36',
            'CPANPLUS::Dist::Build' => 0,
        },
    recommends              => {
            'Test::Output'          => '0.10',
        },
);

$build->create_build_script;


