-module(listutils).		% Utilities for slicing and dicing lists -- probably will be part of a bigger general utils package later
-export([slice/3, member/2]).

slice_r(Max, Max, L, _) ->	% Terminator
        L;

slice_r(N, Max, L, forward) ->	% We are cutting something off the front of the list by taking the tail of the tail of the... etc
	        slice_r(N+1, Max, tl(L), forward);

slice_r(N, Max, L, back) ->	% We are cutting the end off something by reversing it and taking the tail of it, then switching it back, etc.
        slice_r(N + 1, Max, lists:reverse(lists:tl(lists:reverse(L))), back).	% Kludge. There should be a better way.

slice(0, -1, List) ->		% We want the whole thing.
        List;

slice(Start, -1, L) ->		% We want Start to the end
        slice_r(0, Start, L, forward);

slice(0, End, L) ->		% We want everything up to End
        slice_r(0, End, L, back);

slice(Start, End, L) ->		% Sugary default
        slice_r(0, Start, slice_r(0, End, L, back), forward).

member(X, [X|_]) -> true;	% This more or less taken from the manual
member(X, [_|T]) -> member(X, T);
member(_, []) -> false.

