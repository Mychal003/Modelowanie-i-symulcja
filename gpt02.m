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

%% Parametry symulacji
T = 760;
k = 3.5 / 1000;
Tw20 = 15;
Tzero = 40;

Kp = 0.9 * T / (k * Tzero);
Ti = 3.33 * Tzero;
CV = Pgn;

%% Symulacja i wizualizacja

% Parametry pierwszego przypadku
dSP = 5;
deltaTzew = 0;

% Symulacja pierwszego przypadku
assignin('base', 'dSP', dSP);
assignin('base', 'deltaTzew', deltaTzew);
simOut = sim("untitled2.slx", 'StopTime', '5000');
TP_out = simOut.get('TP_out');
czas_sim = simOut.tout;

% Rysowanie pierwszego przypadku
figure;
plot(czas_sim, TP_out, 'r', 'LineWidth', 1, 'DisplayName', 'dSP=5, \DeltaTzew=0');
hold on;

% Parametry drugiego przypadku
dSP = 0;
deltaTzew = 5;

% Symulacja drugiego przypadku
assignin('base', 'dSP', dSP);
assignin('base', 'deltaTzew', deltaTzew);
simOut = sim("untitled2.slx", 'StopTime', '5000');
TP_out = simOut.get('TP_out');

% Rysowanie drugiego przypadku
plot(czas_sim, TP_out, 'b', 'LineWidth', 1, 'DisplayName', 'dSP=0, \DeltaTzew=5');

% Konfiguracja wykresu
xlabel('Czas [s]');
ylabel('Temperatura [°C]');
title('Porównanie przypadków symulacji');
legend('show');
grid on;
