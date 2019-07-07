-module(complex).
-export([arg/1,r/1,sum/2,cAlg2cExp/1,cExp2cAlg/1,power/2]).

%modulo di A+iB
r({complexAlg,A,B}) -> math:sqrt(A*A + B*B) . 

%argomento di A+iB
arg({complexAlg,A,B}) -> 
    if 
        (A == 0.0) and (B > 0.0) -> math:pi()/2;
        (A == 0.0) and (B < 0.0) -> -math:pi()/2;
        (A > 0.0) -> math:atan(B/A);
        (A < 0.0) and (B >= 0.0) -> math:atan(B/A) + math:pi();
        (A < 0.0) and (B < 0.0) -> math:atan(B/A) - math:pi();
        (A==0.0) and (B==0.0) -> io:format("exception: c=0+i0 arg not defined\n")
    end .

sum({complexAlg,A1,B1},{complexAlg,A2,B2}) ->
    {complexAlg, A1+A2, B1+B2} . 

%convertitore da forma algebrica a forma esponenziale
cAlg2cExp ({complexAlg,A,B}) -> 
    R = r({complexAlg,A,B}),
    THETA = arg({complexAlg,A,B}),
    {complexExp,R,THETA} . % c = R*e^(i*THETA)

%convertitore da forma esponenziale a forma algebrica
cExp2cAlg ({complexExp,R,Theta}) ->
    A = R*math:cos(Theta),
    B = R*math:sin(Theta),
    {complexAlg, A,B} . 

%calcolo della potenza N-esima di un complesso in 
%forma esponenziale R*e^(i*THETA)
power(N,{complexExp,R,Theta}) -> 
    {complexExp,math:pow(R,N),N*Theta}.
