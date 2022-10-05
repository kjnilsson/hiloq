-module(hiloq).

-export([
         new/1,
         in/3,
         out/1,
         len/1
         ]).

%% a simple weighted priority queue with only two priorities

-record(?MODULE, {hi = queue:new() :: queue:queue(),
                  lo = queue:new() :: queue:queue(),
                  len = 0 :: non_neg_integer(),
                  weight = 2 :: non_neg_integer(),
                  dequeue_counter = 0 :: non_neg_integer()}).

-opaque state() :: #?MODULE{}.

-export_type([state/0]).

-spec new(non_neg_integer()) ->
    state().
new(Weight) when is_integer(Weight) ->
    #?MODULE{weight = Weight}.

-spec in(hi | lo, term(), state()) -> state().
in(hi, Item, #?MODULE{hi = Hi, len = Len} = State) ->
    State#?MODULE{hi = queue:in(Item, Hi),
                  len = Len + 1};
in(lo, Item, #?MODULE{lo = Lo, len = Len} = State) ->
    State#?MODULE{lo = queue:in(Item, Lo),
                  len = Len + 1}.

out(#?MODULE{len = 0}) ->
    empty;
out(#?MODULE{hi = Hi0, lo = Lo0,
             len = Len, dequeue_counter = C,
             weight = W} = State) ->
    case W == C of
        true ->
            %% try lo before hi
            case queue:out(Lo0) of
                {empty, _} ->
                    {{value, _} = Ret, Hi} = queue:out(Hi0),
                    {Ret, State#?MODULE{hi = Hi,
                                        dequeue_counter = 0,
                                        len = Len - 1}};
                {Ret, Lo} ->
                    {Ret, State#?MODULE{lo = Lo,
                                        dequeue_counter = 0,
                                        len = Len - 1}}
            end;
        false ->
            case queue:out(Hi0) of
                {empty, _} ->
                    {{value, _} = Ret, Lo} = queue:out(Lo0),
                    {Ret, State#?MODULE{lo = Lo,
                                        dequeue_counter = C + 1,
                                        len = Len - 1}};
                {Ret, Hi} ->
                    {Ret, State#?MODULE{hi = Hi,
                                        dequeue_counter = C + 1,
                                        len = Len - 1}}
            end
    end.

len(#?MODULE{len = Len}) ->
    Len.





-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

basics_test() ->
    Q0 = hiloq:new(2),
    Q1 = lists:foldl(
           fun ({P, I}, Q) ->
                   hiloq:in(P, I, Q)
           end, Q0, [
                     {hi, hi1},
                     {lo, lo1},
                     {hi, hi2},
                     {lo, lo2},
                     {hi, hi3}
                    ]),
    {{value, hi1}, Q2} = hiloq:out(Q1),
    {{value, hi2}, Q3} = hiloq:out(Q2),
    {{value, lo1}, Q4} = hiloq:out(Q3),
    {{value, hi3}, Q5} = hiloq:out(Q4),
    {{value, lo2}, _Q6} = hiloq:out(Q5),



ok.
-endif.
