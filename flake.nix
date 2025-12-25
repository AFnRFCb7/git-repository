{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        string ,
                        visitor
                    } :
                        let
                            implementation =
                                {
                                    follow-parent ,
                                    resolutions ,
                                    setup
                                } @set :
                                    {
                                        init =
                                            { mount , pkgs , resources , root , wrap } @primary :
                                                let
                                                    application =
                                                        pkgs.writeShellApplication
                                                            {
                                                                name = "init" ;
                                                                runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                                text =
                                                                    let
                                                                        visitors =
                                                                            {
                                                                                setup =
                                                                                    let
                                                                                        string =
                                                                                            string :
                                                                                                ''
                                                                                                    if [[ -t 0 ]]
                                                                                                    then
                                                                                                        ${ string } "$@"
                                                                                                    else
                                                                                                        cat | ${ string } "$@"
                                                                                                    fi
                                                                                                '' ;
                                                                                        in
                                                                                            {
                                                                                                lambda = path : value : [ ( string ( value primary ) ) ] ;
                                                                                                list = path : list : builtins.concatLists list ;
                                                                                                null = path : value : [ ] ;
                                                                                                set = path : set : builtins.concatLists ( builtins.attrValues set ) ;
                                                                                                string = path : value : [ ( string value ) ] ;
                                                                                            } ;
                                                                            } ;
                                                                        in
                                                                            ''
                                                                                mkdir --parents /mount/repository
                                                                                cd /mount/repository
                                                                                git init 2>&1
                                                                                ${ builtins.concatStringsSep "\n" ( visitor visitors.setup setup ) }
                                                                            '' ;
                                                            } ;
                                                    in "${ application }/bin/init" ;
                                        follow-parent = follow-parent ;
                                        seed =
                                            {
                                                resolutions =
                                                    {
                                                        init = resolutions ;
                                                        release = resolutions ;
                                                    } ;
                                            } ;
                                        targets = [ "repository" "stage" ] ;
                                    } ;
                            in
                                {
                                    check =
                                        {
                                            expected ,
                                            failure ,
                                            follow-parent ? "42647617" ,
                                            mount ? "b72fccc4" ,
                                            pkgs ? "5b31c1f7" ,
                                            resolutions ? "791d986b" ,
                                            resources ?  "5d81ce2a" ,
                                            root ? "801e9b6b" ,
                                            setup ? "5b20c075" ,
                                            wrap ? "63270f12"
                                        } :
                                            pkgs.stdenv.mkDerivation
                                                {
                                                    installPhase = ''execute-test "$out"'' ;
                                                    name = "check" ;
                                                    nativeBuildInputs =
                                                        [
                                                            (
                                                                pkgs.writeShellApplication
                                                                    {
                                                                        name = "execute-test" ;
                                                                        runtimeInputs = [ pkgs.coreutils failure ] ;
                                                                        text =
                                                                            let
                                                                                init = instance.init { mount = mount ; pkgs = pkgs ; resources = resources ; root = root ; wrap = wrap ; } ;
                                                                                instance =
                                                                                    implementation
                                                                                        {
                                                                                            follow-parent = follow-parent ;
                                                                                            resolutions = resolutions ;
                                                                                            setup = setup ;
                                                                                        } ;
                                                                                in
                                                                                    ''
                                                                                        OUT="$1"
                                                                                        touch "$OUT"
                                                                                        ${ if [ "follow-parent" "init" "seed" "targets" ] != builtins.attrNames instance then ''failure fd429b57 git-repository "We expected the names to be init targets but we observed ${ builtins.toJSON ( builtins.attrNames instance ) }"'' else "#" }
                                                                                        ${ if [ "repository" "stage" ] != instance.targets then ''failure 5c205b3b git-repository "We expected the targets to be repository stage but we observed "${ builtins.toJSON instance.targets }"'' else "#" }
                                                                                        ${ if init != expected then ''failure ecfb2043 git-repository "We expected the init to be ${ builtins.toString expected } but we observed ${ builtins.toString init }"'' else "" }
                                                                                    '' ;
                                                                    }
                                                            )
                                                        ] ;
                                                    src = ./. ;
                                                } ;
                                    implementation = implementation ;
                                } ;
            } ;
}
