clear all; close all; clc;
%\ddot{x}+2\cdot\xi\cdot\omega_n\dot{x}+\omega_n^2x=\omega_n^2u

% Definicja parametrów
X = 1;          % Wejście u (lepiej nie zero do 1go)
bX = 1;         % przyrost (w 2gim badaniu bez skok)
E = 1;          % ksi (stanilny/niestab)
W = 0.01;       % Częstotliwość
dx = 1;         
ddx = 1;       
czasskok = 500; 
czassim = 10000; 

% Ustawienie parametrów do b. całk (war poczatkowe mozna przeliczyc)
war1 = 0;                
war2 = dx / (W^2);      

simOut = sim('Fazy1', 'StopTime', num2str(czassim));
%Badanie 1
fig1 = figure();
hold on;
grid on;
title('Odpowiedź skokowa');
xlabel('Czas (s)');
ylabel('x');

x = simOut.get('simout');         
czas_sim = simOut.tout;      

plot(czas_sim, x);

legend('x');

%===== Część III: Portret fazowy
% Pobranie danych do portretu fazowego
xdot = gradient(x, czas_sim); % Numeryczna pochodna

% Rysowanie portretu fazowego
fig2 = figure();
hold on;
grid on;
title('Portret fazowy');
xlabel('x');
ylabel('dx/dt');

% Wykres portretu fazowego
plot(x, xdot, 'LineWidth', 1);

% Dodanie legendy
legend(['\xi = ', num2str(E)]);
