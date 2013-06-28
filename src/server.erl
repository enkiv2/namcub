-module(server).
-record(address, { id,		%% unique ID for document
		   version,	%% version number, increasing integers
		   data}).	%% content
-export([serve/0, start/0, fetch/2, fetch/3, push/3, newest/1, serve_r/0]).
-import(listutils).
-import(qlc).
-include_lib("stdlib/include/qlc.hrl").

serve() ->
	receive
		{fetch, Address, {Start, End}, Sender} ->		% Someone requests a slice of the newest version of a doc
			Sender ! fetch(Address, newest, {Start, End}) ;
		{fetch, Address, Version, {Start, End}, Sender} ->	% Someone requests a slice of a specified version of a doc
			Sender ! fetch(Address, Version, {Start, End}) ;
		{fetch, Address, Version, Sender} ->			% Someone requests the whole of a specified version of a doc
			Sender ! fetch(Address, Version) ;
		{fetch, Address, Sender} ->				% Someone requests the whole of the newest version of a doc
			Sender ! fetch(Address, newest) ;
		{push, Address, Data, Version, Sender} ->		% Someone is uploading a specified version of a doc to you
			Sender ! push(Address, Data, Version) ;
		{push, Address, Data, Sender} ->			% Someone is uploading a new version of a doc to you
			Sender ! push(Address, Data, newest) 
	end.

serve_r() ->	% Recursive helper
	serve(), 
	serve_r().

start() ->		% Call this to start the server. Login server will not use this.
	spawn(server, serve_r, []).

newest(Address) ->	% Tell me the newest version of a doc
	 V =  tl(ets:match(address, {[Address, '$1'], '_'})),
	 list:hd(sort:sort(V)). % Kludge


fetch(Address, newest) ->
	fetch(Address, newest(Address));

fetch(Address, Version) ->
	{push, Address, ets:match(address, {[Address,  Version], '$1'}), Version, self()}.

fetch(Address, Version, {Start, End}) ->
	{push, Address, Data, V, S} = fetch(Address, Version), {push, Address, listutils:slice(Start, End, Data), V, S}.

push(Address, Data, newest) ->
	push(Address, Data, newest(Address)+1);

push(Address, Data, Version) ->
	N = newest(Address),
	 Mem = (ets:match(address, {[Address, Version], '_'}) == []),
	if
		Version > N -> 		% The version is newer than the newest we have, so it's valid -- no overwriting
			mnesia:write(#address{id = Address, version = Version, data = Data}) ;
		Mem =/= true ->		% We were missing that older version, so now we have it -- no overwriting
			mnesia:write(#address{id = Address, version = Version, data = Data}) 
	end.

