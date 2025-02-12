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

%% 3. Obliczenie punktu pracy (punkt równowagi)

Pg0 = Pgn;
Tzew0 = TzewN;

A = [ (Ksl + Ksw), -Ksw;
      -Ksw,       (Ksp + Ksw) ];

B = [ Pg0 + Ksl * Tzew0;
      Ksp * Tzew0 ];

Temps = A \ B;
Tl_eq = Temps(1);
Tp_eq = Temps(2);

disp('Obliczone wartości punktu pracy:');
disp(['Tl_eq = ', num2str(Tl_eq), '°C']);
disp(['Tp_eq = ', num2str(Tp_eq), '°C']);

disp('Nominalne wartości:');
disp(['Tl_nominal = ', num2str(Tl_nominal), '°C']);
disp(['Tp_nominal = ', num2str(Tp_nominal), '°C']);

if abs(Tl_eq - Tl_nominal) < 1e-3 && abs(Tp_eq - Tp_nominal) < 1e-3
    disp('Punkt pracy zgadza się z wartościami nominalnymi.');
else
    disp('Punkt pracy NIE zgadza się z wartościami nominalnymi.');
end

%% 4. Wybór jednego przypadku i symulacja

% Parametry skoku i symulacji
czasskok = 500;       % Czas skoku [s]
czas_symulacji = 5000; % Czas symulacji [s]

% Przypadek: Brak zmiany Tzew, zmiana Pg o 20%
Tzew0 = TzewN;    % Temperatura zew. nominalna
Pg0 = Pgn;        % Moc grzałki nominalna
deltaTzew = 0;    % Brak zmiany temperatury zewnętrznej
delta_Pg = 1.1;   

% Przekazanie zmiennych do workspace (jeśli model tego wymaga)
assignin('base', 'Tzew0', Tzew0);
assignin('base', 'deltaTzew', deltaTzew);
assignin('base', 'Pg0', Pg0);
assignin('base', 'delta_Pg', delta_Pg);
assignin('base', 'czasskok', czasskok);

% Ponowne wyliczenie punktu równowagi dla danych wejściowych
A = [ (Ksl + Ksw), -Ksw;
      -Ksw,       (Ksp + Ksw) ];

B = [ Pg0 + Ksl * Tzew0;
      Ksp * Tzew0 ];

Temps = A \ B;
Tl_eq = Temps(1);
Tp_eq = Temps(2);

% Symulacja obiektu
simOut = sim("untitled.slx", 'StopTime', num2str(czas_symulacji));

% Wyodrębnienie wyników symulacji
TP_out = simOut.get('TP_out');
czas_sim = simOut.tout;

% Zapisanie wyników pierwszej symulacji do oddzielnych zmiennych
TP_out_1 = TP_out;
czas_sim_1 = czas_sim;


%% Parametry modelu (Część 2)
T = 760;
k = 3.5 / 1000;
Tw20 =15;
dPg=0.1*Pgn;
Tzero=600;

%% 4. Symulacja modelu (untitled1.slx)

simOut = sim('untitled1.slx', 'StopTime', num2str(czas_symulacji));

% Wyodrębnienie wyników symulacji
czas_sim = simOut.tout;
TP_out = simOut.get('TP_out2');

% Zapisanie wyników drugiej symulacji do oddzielnych zmiennych
TP_out_2 = TP_out;
czas_sim_2 = czas_sim;

%% 5. Rysowanie wykresu na jednym rysunku

figure;
plot(czas_sim_1, TP_out_1, 'b', 'LineWidth', 1); 
hold on;
plot(czas_sim_2, TP_out_2, '--', 'LineWidth', 1);
xlabel('Czas [s]');
ylabel('Temperatura w prawym pokoju [\circC]');
title('Zmiana temperatury w prawym pokoju');
grid on;
legend(sprintf('Tzew0=%.1f\\circC, \\DeltaPg=%.1f (obiekt)', TzewN, delta_Pg), ...
       sprintf('Tzew0=%.1f\\circC, \\DeltaPg=%.1f (druga symulacja, model)', TzewN, delta_Pg));
