-module(server).
-export ([man_server/4,matrixAgent/0]).

man_server(NAgents,Step,Limit,VerboseLevel) ->
    % Y range -2, 1
    DeltaX = 3.0/NAgents,
    Ranges = [ {range,-2.0+N*DeltaX,-2.0+(N+1)*DeltaX,-1.0,1.0} || N <- mset:range(0,NAgents,1)],
    Agents = [ spawn(server, matrixAgent, []) || N <- mset:range(0,NAgents,1)],
    Attribuzioni = lists:zip(Agents,Ranges),

    lists:foreach(fun({A,R}) -> A ! {R,Step,Limit,VerboseLevel,self()} end, Attribuzioni ),

    lists:foreach(
        fun(N) ->
            receive
                {done,_} -> io:format("processo done\n",[]);
                error -> 
                    io:format("error")
                after 10 -> io:format("qualcosa non gira\n")

            end
        end
         ,mset:range(0,NAgents,1) ),

    lists:foreach(fun(A) -> A!stop end, Agents)
.


matrixAgent() -> 
    %VerboseLevel: 0 solo fine calcolo sottomatrice totale, 1 risultato finale per ogni C , 2 singole iterazioni
    receive 
        {{range,Xl,Xr,Yb,Yt},Step,Limit,VerboseLevel,Pid} ->
            Filename = "outdata/range"++io_lib:format("~.2f", [Xl])++" "++io_lib:format("~.2f", [Xr])++" "++
                        io_lib:format("~.2f", [Yb])++" "++io_lib:format("~.2f", [Yt])++".csv",
            
            case file:open(Filename, [append]) of %apro il file
                {ok, IoDevice} ->
                    Fun = fun(P) -> 
                                Result = mset:start_serie(P,Limit,VerboseLevel) ,
                                Bytes = alg2string(P)++" , "++io_lib:format("~p", [Result])++"\n",
                                file:write(IoDevice, Bytes)
                            end,
                    Pairs = [{complexAlg,X,Y} || X <- mset:range(Xl,Xr,Step), Y <- mset:range(Yb,Yt,Step)],
                    lists:foreach (Fun, Pairs ),
                    io:format("FINE CALCOLO MATRICE DI APPARTENENZA\n",[]),
                    file:close(IoDevice),
                    Pid ! {done,self()},
                    matrixAgent();
                {error, Reason} ->
                    io:format("~s open error  reason:~s~n", [Filename, Reason]),
                    Pid ! error ,
                    matrixAgent()
                end;
            stop -> io:format(" Server stopping ... \n", []);
            _ -> 
                io:format("messaggi non ben formato\n")
            after 5000 -> io:format("se non mi invii niente mi spengo!\n")
        end
    .


alg2string({complexAlg,X,Y}) ->
    Xs = io_lib:format("~.2f", [X]),
    Ys = io_lib:format("~.2f", [Y]),
    Xs++" , "++Ys .