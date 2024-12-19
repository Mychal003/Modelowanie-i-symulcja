clc; clear all; close all;

%% 1. Wyznaczenie parametrów modelu

% Wartości nominalne
TzewNom = -20;
TzewN = -20;  % Temperatura zewnętrzna [°C]
Tl_nominal = 20; % Nominalna temperatura w lewym pokoju [°C]
Tp_nominal = 15; % Nominalna temperatura w prawym pokoju [°C]

a = 2; % Współczynnik przenikania ciepła [W/°C]
B = 5; % Grubość ściany działowej [m]
Pgn = 10000; % Moc grzałki [W]

% Wymiary pokoi
x = (50 / B * 2 + 5) / 3;
y = (x - 5) / 2;

Vp = B * x * 3; % Objętość prawego pokoju [m^3]
Vl = B * y * 3; % Objętość lewego pokoju [m^3]

% Parametry powietrza
Cp = 1000; % Ciepło właściwe powietrza [J/(kg*K)]
rop = 1.2; % Gęstość powietrza [kg/m^3]

% Pojemności cieplne
Cvp = Cp * rop * Vp; % Pojemność cieplna prawego pokoju [J/°C]
Cvl = Cp * rop * Vl; % Pojemność cieplna lewego pokoju [J/°C]

%% 2. Obliczenie przewodności cieplnych

Ksp = Pgn / (a * (Tl_nominal - TzewN) + (Tp_nominal - TzewN));
Ksl = a * Ksp;
Ksw = Ksp * (Tp_nominal - TzewN) / (Tl_nominal - Tp_nominal); % Przewodność cieplna między pokojami

%% 3. Punkt pracy i symulacja

% Parametry symulacji
czasskok = 1000;       % Czas skoku [s]
czas_symulacji = 10000; % Czas symulacji [s]

% Parametry skoku
deltaTzew = 0;         % Brak zmiany temperatury zewnętrznej
delta_Pg = 1.1;         % Zwiększenie mocy grzałki o 10%
Pg0 = Pgn;

% Parametry dodatkowe
T = 1855;
k = 3.5 / 1000;
Tw20 = 15;

% Przekazanie zmiennych do workspace
assignin('base', 'TzewN', TzewN);
assignin('base', 'Pg0', Pg0);
assignin('base', 'delta_Pg', delta_Pg);
assignin('base', 'czasskok', czasskok);
assignin('base', 'Tw20', Tw20);

%% 4. Symulacja modelu

% Symulacja pliku Simulinka "untitled1.slx"
simOut = sim('untitled1.slx', 'StopTime', num2str(czas_symulacji));

% Wyodrębnienie wyników symulacji
czas_sim = simOut.tout;
TP_out = simOut.get('TP_out'); % Zakładam, że TP_out to wyjście temperatury w prawym pokoju

%% 5. Rysowanie wykresu

figure;
plot(czas_sim, TP_out, 'b', 'LineWidth', 1.5);
xlabel('Czas [s]');
ylabel('Temperatura w prawym pokoju [\circC]');
title('Zmiana temperatury w prawym pokoju');
grid on;
legend(sprintf('Tzew0=%.1f\circC, \DeltaPg=%.1f', TzewN, delta_Pg));
