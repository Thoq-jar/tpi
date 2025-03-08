-module(tpi_erlang).

-export([run_cmd_erl/1]).

run_cmd_erl(Command) ->
    CmdStr = binary_to_list(Command),
    Dir = "/tmp/tpi",
    case filelib:is_dir(Dir) of
        false -> file:make_dir(Dir);
        true -> ok
    end,
    ok = file:set_cwd(Dir),
    Result = os:cmd(CmdStr),
    list_to_binary(Result).
