-module(loginserver).
-export([start/0, serve/0, serve_r/0, login/3, register_account/2, logout/1]).
-import(server).
-include_lib("stdlib/include/qlc.hrl").
-record(account, { uname,
		   pass}).

-record(active, {  uname,
		   handle}).

serve() -> 
	server:serve(),
	receive
		{register_account, Name, Pass, Sender} ->
			Sender ! register_account(Name, Pass);
		{login, Name, Pass, Sender} ->
			Sender ! login(Name, Pass, Sender);
		{logout, Sender} ->
			Sender ! logout(Sender) 
	end.

serve_r() ->
	serve(),
	serve_r().

start() ->
	spawn(loginserver, serve_r, []).

register_account(Name, Pass) ->
	N = ets:match(account, { Name, '$2'}),
	if N == [] ->
		ets:insert(account, {Name, Pass})
	end.

login(Name, Pass, Sender) ->
	N = ets:match(account, {Name, '$2'}),
	if N == Pass ->
		Sender ! ok
	end.

logout(Sender) ->
	ok. % does nothing
