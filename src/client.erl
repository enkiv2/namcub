-module(client).
-export([init/0, mainloop/0]).
-import(server).
-import(i3span_editor).

init() ->
	server:start(),
	S = gs:start(),
	W = gs:create(window, loginwin, S, []),
	gs:create(entry, uname, W, [{width, 100}, {x, 10}, {y, 30}, {text, "username"}]),
	gs:create(entry, pass, W, [{width, 100}, {x, 210}, {y, 30}, {text, "password"}]),
	gs:create(button, login, W, [{label, {text, "Log in"}}, {x, 400}, {y, 100}]),
	gs:create(button, register, W, [{label, {text, "Register"}}, {x, 200}, {y, 100}]),
	gs:config(W, {map, true}),
	mainloop().

mainloop() ->
	receive
		{gs, b1, click, _, _}	->
			login(gs:read(uname, text), gs:read(pass, text));
		{ok, S} ->
			X=spawn(i3span_editor, display, [self(), 0, newest, '', S]),
			S ! {fetch, 0, X}
	end,
	mainloop().

login(Uname, Pass) ->
	LoginServer = getLoginServer(),
	LoginServer ! {login, Uname, Pass, self()}.

getLoginServer() ->
	self(). % For testing only

