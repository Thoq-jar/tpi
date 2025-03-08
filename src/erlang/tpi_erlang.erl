-module(tpi_erlang).

-export([run_cmd_erl/1]).

run_cmd_erl(Command) ->
    CmdStr = binary_to_list(Command),
    Result = os:cmd(CmdStr),
    list_to_binary(Result).
