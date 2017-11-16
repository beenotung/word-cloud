-module(main).
-compile(export_all).

test() ->
  {ok, Bin} = file:read_file("data.txt"),
  Str = binary_to_list(Bin),
  Words = split_word(Str),
  WordCount = count_word(Words),
  sort_word_count(WordCount).

-define(is_eng(C), (($a =< C andalso C =< $z) or ($A =< C andalso C =< $Z))).
-define(is_digit(C), ($0 =< C andalso C =< $9)).
-define(is_char(C), (?is_eng(C) or ?is_digit(C)) or (C == $')).

debug() ->
  dbg:start(),
  dbg:tracer(),
  debug2(),
  dbg:p(all, c).

debug2() ->
  dbg:tpl(?MODULE, '_', []).

stop_words() ->
  {ok, Bin} = file:read_file("stop.txt"),
  List = binary_to_list(Bin),
  [Word, Acc] = lists:foldl(
    fun(W, [Word, Acc]) ->
      case W of
        $\n -> [[], [lists:reverse(Word) | Acc]];
        _ -> [[W | Word], Acc]
      end
    end, [[], []], List),
  Res = [lists:reverse(Word) | Acc],
%%  io:format("Res=~p~n", [Res]),
  Res.

is_stop_word([], _) ->
  true;
%%is_stop_word(Word, [Word | _]) ->
%%  true;
is_stop_word(Word, [H | StopWords]) ->
  case string:equal(Word, H, true) of
    true -> true;
    false -> is_stop_word(Word, StopWords)
  end;
is_stop_word(_, []) ->
  false.

split_word(Str) ->
  List = split_word(Str, [], []),
  StopWords = stop_words(),
  lists:filter(
    fun(Word) ->
      Res = not is_stop_word(Word, StopWords),
%%      if not Res ->
%%        io:format("drop ~p~n", [Word]);
%%        true -> ok
%%      end,
      Res
    end, List).

split_word([], [], Acc) ->
  lists:reverse(Acc);
split_word([], Word, Acc) ->
  split_word([], [], [lists:reverse(Word) | Acc]);
split_word([H | T], Word, Acc) when ?is_char(H) ->
  split_word(T, [H | Word], Acc);
split_word([H | T], Word, Acc) ->
%%  io:format("skip ~p~n", [[H]]),
  W = lists:reverse(Word),
  split_word(T, [], [W | Acc]).

count_word(List) ->
  lists:foldl(
    fun(Word, Acc) ->
      C = maps:get(Word, Acc, 0),
      maps:put(Word, C + 1, Acc)
    end, #{}, List).

sort_word_count(Map) ->
  List = maps:to_list(Map),
  lists:keysort(2, List).


