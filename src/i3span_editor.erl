-module(i3span_editor).
-export([display/5]).

display(ParentPID, Address, Version, Data, Server) ->
	S = gs:start(),
	W = gs:create(window, i3span_w, S, []),
	gs:create(editor, i3span_ed, W, [{x, 0}, {y, 0}, {width, 400}]),
	gs:config(i3span_ed, {insert, {'end', Data}}),
	gs:config(W, {map, true}),
	mainloop(ParentPID, Address, Version, Server).

mainloop(ParentPID, Address, _, Server) ->
	receive
		{gs, i3span_ed, keypress, ['Control', p]} ->
			Server ! {push, Address, gs:read(i3span_ed, text), ParentPID} ;
		{gs, i3span_ed, keypress, ['Control', r]} ->
			Server ! {fetch, Address, ParentPID},
			ParentPID ! {fetch, Address, self()};
		{push, Address, _, D, ParentPID} ->
			gs:config(i3span_ed, clear),
			gs:config(i3span_ed, {insert, {'end', D}})
	end.

