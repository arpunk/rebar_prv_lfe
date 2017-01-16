-module(rebar_prv_lfe_repl).

-behaviour(provider).

-export([init/1,
         do/1,
         format_error/1]).

-define(PROVIDER, repl).
-define(NAMESPACE, lfe).
-define(DEPS, [{default, compile}]).

%% ===================================================================
%% Public API
%% ===================================================================

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
    State1 = rebar_state:add_provider(
            State,
            providers:create([
                {name, ?PROVIDER},
                {module, ?MODULE},
                {namespace, ?NAMESPACE},
                {bare, true},
                {deps, ?DEPS},
                {example, "rebar3 lfe repl"},
                {short_desc, "Run LFE REPL with project apps and deps in path."},
                {opts, [{config, undefined, "config", string,
                         "Path to the config file to use. Defaults to "
                         "{shell, [{config, File}]} and then the relx "
                         "sys.config file if not specified."},
                        {name, undefined, "name", atom,
                         "Gives a long name to the node."},
                        {sname, undefined, "sname", atom,
                         "Gives a short name to the node."},
                        {setcookie, undefined, "setcookie", atom,
                         "Sets the cookie if the node is distributed."},
                        {script_file, undefined, "script", string,
                         "Path to an escript file to run before "
                         "starting the project apps. Defaults to "
                         "rebar.config {shell, [{script_file, File}]} "
                         "if not specified."},
                        {apps, undefined, "apps", string,
                         "A list of apps to boot before starting the "
                         "shell. (E.g. --apps app1,app2,app3) Defaults "
                         "to rebar.config {shell, [{apps, Apps}]} or "
                         "relx apps if not specified."}]}
            ])
    ),
    {ok, State1}.

-spec do(rebar_state:t()) -> {ok, rebar_state:t()} | {error, string()}.
do(State) ->
    ReplOpts = rebar_state:get(State, lfe_shell, []),
    ShellOpts = ReplOpts ++ rebar_state:get(State, shell, []),
    State1 = rebar_state:set(State, shell, [{shell_args, ['tty_sl -c -e',{lfe_shell,start,[]}]} | ShellOpts]),
    rebar_prv_shell:do(State1),
    {ok, State1}.

-spec format_error(any()) -> iolist().
format_error(Reason) ->
io_lib:format("~p", [Reason]).
