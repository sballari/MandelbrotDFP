- module(mset).
- export ([f/2,serie/5,start_serie/3,range/3]).

range(N,M,Step) -> 
    if 
        N>=M -> [] ;
        N < M -> [N | range(N+Step,M,Step)] 
    end .

f({complexAlg,Ca,Cb},{complexAlg,Za,Zb}) -> % fc(z) = z^2 + c
    if 
        (Za==0) and (Zb==0) -> 
            {complexAlg,Ca,Cb}; % 0^2 + c, 
            %caso a parte altrimento conversione a exp non definita (calcolo argomento)
        true -> %otherwise
            Zexp = complex:cAlg2cExp({complexAlg,Za,Zb}),
            Zp2 = complex:power(2.0,Zexp),
            Zp2Alg = complex:cExp2cAlg(Zp2),
            complex:sum(Zp2Alg,{complexAlg,Ca,Cb})
    end
.

serie({complexAlg,Ca,Cb}, {complexAlg,Za,Zb}, N, Limit, Verbose) ->
    % N : iterazione corrente
    % Limit : iterazione a cui fermarsi
    % verbose : stampa delle iterazione Zn
    % return : # dell'iterazione a cui la serie diverge o il limite
    Calg = {complexAlg,Ca,Cb},
    Zalg = {complexAlg,Za,Zb},
    
    if
        N >= Limit -> 
            if  Verbose -> 
                    io:format("reach limit\n");
                true -> {} 
            end,
            Limit;
        N == 0 -> 
            if  Verbose -> 
                    io:format("Z0 = (0+i*0)\n"); 
                true -> {} 
            end,
            serie(Calg,{complexAlg,0.0,0.0},1,Limit,Verbose);
        true -> %otherwise
            Fz = f(Calg,Zalg), %calcolo iterazione N-sima (Zn)
            {complexAlg, X,Y} = Fz ,
            R_Fz = complex:r(Fz), %modulo iterazione N-sima
            if
                R_Fz > 2 -> %iterazione N diverge
                    if  Verbose ->
                            io:format("Z~B = (~f + i*~f) \n",[N,X,Y]),
                            io:format("module > 2\n");
                        true -> {}
                    end,
                    N; 
                true -> %la serie non ancora diverge
                    if  Verbose -> 
                            io:format("Z~B = (~f + i*~f) \n",[N,X,Y]);
                        true -> {}
                    end,
                    serie(Calg,Fz,N+1,Limit,Verbose)
            end
    end
.
     
start_serie({complexAlg,A,B},Limit,VerboseLevel)  ->
    %return iterazione a cui diverge o limite
    %VerboseLevel: 0 niente, 1 risultato finale , 2 singole iterazioni 
    
    case VerboseLevel of
        0 -> Verbose = false,Verbose2 = false ;
        1 -> Verbose = false,Verbose2 = true;
        2 -> Verbose = true,Verbose2 = true;
        _ -> Verbose = false,Verbose2 = false 
    end,

    CAlg = {complexAlg,A,B},

    StartTm = erlang:system_time(millisecond),
    It = serie(CAlg,{complexAlg,0.0,0.0},0,Limit,Verbose), %calcolo serie effettivo
    TempoExGlobale = erlang:system_time(millisecond) - StartTm,

    if  Verbose2 -> 
            io:format("C = (~f+i*~f) \titerazioni:~B \ttm=~Bms\n",[A,B,It,TempoExGlobale]);
        true -> {}
    end,

    It.



