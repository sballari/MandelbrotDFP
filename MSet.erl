- module(mset).
- export ([f/2,serie/4]).

range(N,M,Step) -> 
    if 
        N>=M -> [] ;
        N < M -> [N | range(N+Step,M,Step)] 
    end .

f({complexAlg,Ca,Cb},{complexExp,Zr,ZTh}) -> % f(c,z) = z^2 + c
    Zp2 = complex:power(2,{complexExp,Zr,ZTh}),
    Zp2Alg = complex:cExp2cAlg(Zp2),
    complex:sum(Zp2Alg,{complexAlg,Ca,Cb})
.


% diver :: complexAlg -> complexAlg -> (Int:risultato prec) -> (Int:iterazione) -> (Int:diverge all'iter ...)

serie(Calg ,_ , 0, Limit) -> 
    io:format("Z0 = 0\n"),
    serie(Calg,{complexAlg,0,0},1,Limit);

serie({complexAlg,Ca,Cb}, {complexAlg,Za,Zb}, N, Limit) ->
    Calg = {complexAlg,Ca,Cb},
    Zalg = {complexAlg,Za,Zb},
    Zexp = complex:cAlg2cExp(Zalg),
    Fz = f(Calg,Zexp),
    {complexAlg, X,Y} = Fz ,
    R_Fz = complex:r(Fz),
    
    if
        N == Limit -> 
            io:format("rech limit\n"),
            Limit;
        R_Fz > 2 -> 
            io:format("Z ~B = (~f + i*~p) \n",[N,X,Y]),
            io:format("module > 2\n"),
            N;
        true -> %la serie non ancora diverge
            io:format("Z ~B = ~f + i*~p \n",[N,X,Y]),
            serie(Calg,Fz,N+1,Limit)
    end
.
     
        

    


% mMatrix(N,M,Step) -> 
%     Pairs = [ {X,Y} || X <- range(0,N,Step), Y <- range(0,M,Step)],
%     lists:map (fun(P) -> spawn(mset, f, [{complex}]) end , Pairs ) . 

