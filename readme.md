Froblib
===========

Basically the idea is that you can take a table and `frob.extend(t, frob.class)` in order to define behavior
There's also an `append()` function that you can use to keep the top level free from garbage but it won't always work, especially if the component uses `self` to reference the whole table.

Yes I realize my documentation sucks.