d(Var, Func, 0) :-
    atomic(Var), number(Func).

d(Var, Func, 1) :-
    Var == Func.

d(Var, N*Var, N) :-
    atomic(Var), number(N).

d(Var, Var^N, N*Var^Nm1) :-
    number(N), is(Nm1, N - 1).

d(Var, K*Var^N, C*Var^Nm1) :-
    atomic(Var), number(K), number(N), is(C, K*N), is(Nm1, N-1).

d(Var, log(Var), 1/Var) :-
    atomic(Var).

s(Var, K, K*Var) :-
    number(K), atomic(Var).

s(Var, Var, 1/2*Var^2) :-
    atomic(Var).

s(Var, K*Var^N, K/M*Var^M) :-
    atomic(Var), number(K), number(N), is(M, N+1).

sumar(Var, A+B, R) :-
    atomic(Var), simplificar(Var, A+B, R).

restar(Var, A-B, R) :-
    atomic(Var), simplificar(Var, A-B, R).

simplificar(Var, Expr, R) :-
    terminos(Var, Expr, Lista),
    agrupar(Lista, Agrupados),
    quitar_ceros(Agrupados, SinCeros),
    ordenar(SinCeros, Ordenados),
    construir(Var, Ordenados, R).

monomio(_, K, K, 0) :-
    number(K), !.
monomio(Var, Var, 1, 1) :- !.
monomio(Var, Var^N, 1, N) :-
    number(N), !.
monomio(Var, K*Var, K, 1) :-
    number(K), !.
monomio(Var, K*Var^N, K, N) :-
    number(K), number(N), !.
monomio(Var, -T, C, N) :-
    monomio(Var, T, C0, N), C is -C0.

terminos(Var, A+B, L) :- !,
    terminos(Var, A, LA),
    terminos(Var, B, LB),
    append(LA, LB, L).
terminos(Var, A-B, L) :- !,
    terminos(Var, A, LA),
    terminos(Var, B, LB),
    negar(LB, LBNeg),
    append(LA, LBNeg, L).
terminos(Var, T, [C-N]) :-
    monomio(Var, T, C, N).

negar([], []).
negar([C-N|R], [C2-N|R2]) :-
    C2 is -C, negar(R, R2).

agrupar([], []).
agrupar([C-N|R], [S-N|G]) :-
    sumar_grado(N, R, C, S, Resto),
    agrupar(Resto, G).

sumar_grado(_, [], S, S, []).
sumar_grado(N, [C-M|R], Acc, S, Resto) :-
    M =:= N, !,
    Acc1 is Acc + C,
    sumar_grado(N, R, Acc1, S, Resto).
sumar_grado(N, [T|R], Acc, S, [T|Resto]) :-
    sumar_grado(N, R, Acc, S, Resto).

quitar_ceros([], []).
quitar_ceros([C-_|R], L) :-
    C =:= 0, !, quitar_ceros(R, L).
quitar_ceros([T|R], [T|L]) :-
    quitar_ceros(R, L).

ordenar([], []).
ordenar([T|R], L) :-
    ordenar(R, LR), insertar(T, LR, L).

insertar(T, [], [T]).
insertar(C-N, [C2-N2|R], [C-N, C2-N2|R]) :-
    N >= N2, !.
insertar(T, [T2|R], [T2|L]) :-
    insertar(T, R, L).

construir(_, [], 0).
construir(Var, [C-N|R], Expr) :-
    termino(Var, C, N, T),
    construir_resto(Var, R, T, Expr).

construir_resto(_, [], Acc, Acc).
construir_resto(Var, [C-N|R], Acc, Expr) :-
    C < 0, !,
    CAbs is -C,
    termino(Var, CAbs, N, T),
    construir_resto(Var, R, Acc-T, Expr).
construir_resto(Var, [C-N|R], Acc, Expr) :-
    termino(Var, C, N, T),
    construir_resto(Var, R, Acc+T, Expr).

termino(_, C, 0, C) :- !.
termino(Var, C, 1, Var) :- C =:= 1, !.
termino(Var, C, 1, -Var) :- C =:= -1, !.
termino(Var, C, 1, C*Var) :- !.
termino(Var, C, N, Var^N) :- C =:= 1, !.
termino(Var, C, N, -(Var^N)) :- C =:= -1, !.
termino(Var, C, N, C*Var^N).
