-module(server).
-export ([stdrange_man/4, man_server/9,matrixAgent/0,funOverRange/5]).


stdrange_man(NAgents,NBatch,Step,Limit) ->
    man_server(NAgents,NBatch,Step,Limit,0,-2.0,1.0,-1.0,1.0).

man_server(NAgents,NBatch,Step,Limit,VerboseLevel,Xmin,Xmax,Ymin,Ymax) ->
    % Y range -2, 1
    StartTm = erlang:system_time(millisecond),
    %divido il lavoro in range
    DeltaX = (Xmax-Xmin)/NBatch,
    Ranges = [ {range,Xmin+N*DeltaX,Xmin+(N+1)*DeltaX,Ymin,Ymax} || N <- mset:range(0,NBatch,1)],
      
    Agents = [ spawn(server, matrixAgent, []) || _ <- mset:range(0,NAgents,1)], 
    

    %Mando i primi lavori al rispettivo agente
    {FirstN, WRest} = lists:split(NAgents,Ranges),
    Attribuzioni = lists:zip(Agents,FirstN),
    lists:foreach(fun({A,R}) -> A ! {R,Step,Limit,VerboseLevel,self()} end, Attribuzioni ),

    %attendo le NBatch risposte
    case waitAndSend(WRest,Step,Limit,VerboseLevel) of 
        done -> %tutti i work sono stati mandati
            %ricevo gli ultimi Nagents processi non ricevuti da waitAndSend
            lists:foreach(fun(_)-> 
                receive
                    {done,_} -> 
                        io:format("processo done\n");
                    error -> 
                        io:panic("error negli ultimi processi\n"),
                        fail
                end
            end,mset:range(0,NAgents,1)),
            FinalTime = erlang:system_time(millisecond) - StartTm,
            io:format("FINE CALCOLO files MATRICE \ttm=~Bms\n",[FinalTime]);
        fail ->  io:panic("ERRORE, cartella ospite probabilmente non creata")
    end,

    %in ogni caso fermo i processi
    lists:foreach(fun(A) -> A!stop end, Agents) 
.

    
waitAndSend(Works,Step,Limit,VerboseLevel) -> 
    case Works of 
        [] -> 
            io:format("tutti i work sono stati mandati\n"),
            done ;
        [Work|Ws] -> 
            receive 
                {done,Pid} -> 
                    io:format("processo done, invio nuovo lavoro\n"),
                    Pid ! {Work,Step,Limit,VerboseLevel,self()},
                    waitAndSend(Ws,Step,Limit,VerboseLevel);
                error -> 
                    io:panic("error, inutile rimandare stop\n"),
                    fail
            end
    end
.

%Xmax,Ymin esclusi
funOverRange(X,Y,Fun,{range, XMin,XMax,YMin,YMax},Step) ->
    if 
        (X < XMax) and (Y < YMax) -> 
            P = {complexAlg,X,Y},
            Fun(P),
            funOverRange(X, Y+Step, Fun,{range, XMin,XMax,YMin,YMax},Step);
        (X < XMax) and (Y >= YMax) -> 
            funOverRange(X+Step,YMin, Fun,{range, XMin,XMax,YMin,YMax},Step);
        (X>=XMax) -> done;
        true -> io:panic("pattern non esaustivo!")
    end . 
        

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
                    % Pairs = [{complexAlg,X,Y} || X <- mset:range(Xl,Xr,Step), Y <- mset:range(Yb,Yt,Step)],
                    % lists:foreach (Fun, Pairs ),
                    funOverRange(Xl,Yb,Fun,{range,Xl,Xr,Yb,Yt},Step),
                    io:format("FINE CALCOLO SOTTO-MATRICE ~.2f ~.2f\n",[Xl,Xr]),
                    file:close(IoDevice),
                    Pid ! {done,self()},
                    matrixAgent();
                {error, Reason} ->
                    io:panic("~s open error  reason:~s~n", [Filename, Reason]),
                    Pid ! error ,
                    matrixAgent()
            end;
        stop -> io:format(" Server stopping ... \n", []);
        _ -> 
            io:format("messaggio non ben formato\n")
        % after 5000 -> servirebbe gestione errori dal padre
        %     io:panic("se non mi invii niente mi spengo!\n")
        end
    .


alg2string({complexAlg,X,Y}) ->
    Xs = io_lib:format("~.5f", [X]),
    Ys = io_lib:format("~.5f", [Y]),
    Xs++" , "++Ys .