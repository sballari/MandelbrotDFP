- module(mset).
- export ([f/2,serie/4,mMatrix/4,start_serie/2,mMatrixSeq/4]).

range(N,M,Step) -> 
    if 
        N>=M -> [] ;
        N < M -> [N | range(N+Step,M,Step)] 
    end .

f({complexAlg,Ca,Cb},{complexAlg,Za,Zb}) -> % f(c,z) = z^2 + c
    if 
        (Za==0) and (Zb==0) -> 
            {complexAlg,Ca,Cb}; % 0^2 + c
        true ->
            Zexp = complex:cAlg2cExp({complexAlg,Za,Zb}),
            Zp2 = complex:power(2.0,Zexp),
            Zp2Alg = complex:cExp2cAlg(Zp2),
            complex:sum(Zp2Alg,{complexAlg,Ca,Cb})
    end
.


%  diver :: complexAlg -> 
%           complexAlg -> 
%           (Int:risultato prec) ->
%           (Int:iterazione) ->
%           (Int:diverge all'iter ...)

serie({complexAlg,Ca,Cb}, {complexAlg,Za,Zb}, N, Limit) ->
    Calg = {complexAlg,Ca,Cb},
    Zalg = {complexAlg,Za,Zb},
    
    if
        N == Limit -> 
            io:format("reach limit\n"),
            Limit;
        true ->
            Fz = f(Calg,Zalg),
            {complexAlg, X,Y} = Fz ,
            R_Fz = complex:r(Fz),
            if
                R_Fz > 2 -> 
                    io:format("Z ~B = (~f + i*~f) \n",[N,X,Y]),
                    io:format("module > 2\n"),
                    N;
                true -> %la serie non ancora diverge
                    io:format("Z ~B = (~f + i*~f) \n",[N,X,Y]),
                    serie(Calg,Fz,N+1,Limit)
            end
    end
.
     
start_serie(CAlg,Limit)  ->
    io:format("Z0 = (0+i*0)\n"),
    serie(CAlg,{complexAlg,0.0,0.0},1,Limit).

    


mMatrix(N,M,Step,Limit) -> 
    Pairs = [ [{complexAlg,X,Y} || X <- range(0.0,N,Step)] || Y <- range(0.0,M,Step)],
    lists:map (fun(Row) -> lists:map (fun(P) -> spawn(mset, start_serie, [P,Limit]) end,Row ) end, Pairs ) 
. 

mMatrixSeq(N,M,Step,Limit) -> 
    Pairs = [ [{complexAlg,X,Y} || X <- range(0.0,N,Step)] || Y <- range(0.0,M,Step)],
    lists:map (
        fun(Row) -> lists:map (
            fun(P) -> 
                It = start_serie(P,Limit),
                if 
                    It < Limit -> "*" ;
                    true -> " " 
                end  
            end,Row ) end, Pairs ) 
. 