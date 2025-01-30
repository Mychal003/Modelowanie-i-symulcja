clc;clear all;close all;
tspan = [ 0 200];
y0 = 0;
Rp = 0.8;
r=0.1;
Rv=1.2;
a = 0.6;
b = 0.5;
m = 0.05;

V = 20;
P = 10;
czas_symulacji=1000;
%options = odeset(MaxStep=0.1);
% Symulacja obiektu
simOut = sim("Lotkasim.slx", 'StopTime', num2str(czas_symulacji));

% Wyodrębnienie wyników symulacji
P_out = simOut.get('simout');
V_out = simOut.get('simout1');
czas_sim = simOut.tout;
%rowniania = @(t, y) [r * y(1) - a * y(1) * y(2); b * y(1) * y(2) - m * y(2)]; %dx/dy % dy/dt

assignin('base', 'Rp', Rp);

for i = 1:1:1

    figure(Name="Populacja rozmiar")
    plot(P_out,V_out);
    xlabel("Czas");
    ylabel("Liczebnosc");
    legend("ofiary", "drapiezniki");
end
figure(Name="Wykres fazowy");



for i=1:1:1
    [t, y] = ode23(rowniania, tspan, [V, P]);
    plot(y(:,1), y(:,2))
    hold on;
    xlabel("ofiary");
    ylabel("drapiezniki");
end

r=1;
rowniania = @(t, y) [r * y(1) - a * y(1) * y(2); b * y(1) * y(2) - m * y(2)]; %dx/dy % dy/dt
for i = 1:1:5

    [t, y] = ode23(rowniania, tspan, [V, P]);
    figure(Name="Populacja rozmiar z rozrodczosc ofiar=2")
    plot(t,y);
    xlabel("Czas");
    ylabel("Liczebnosc");
    legend("ofiary", "drapiezniki");
end