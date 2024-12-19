clc; clear all; close all;

%% 1. Wyznaczenie parametrów modelu (pierwszy model)

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
Ksw = Ksp * (Tp_nominal - TzewN) / (Tl_nominal - Tp_nominal);

%% 3. Obliczenie punktu pracy (punkt równowagi) - pierwszy model
Pg0 = Pgn;
Tzew0 = TzewN;

A = [ (Ksl + Ksw), -Ksw;
      -Ksw,        (Ksp + Ksw) ];

B = [ Pg0 + Ksl * Tzew0;
      Ksp * Tzew0 ];

Temps = A \ B;
Tl_eq = Temps(1);
Tp_eq = Temps(2);

disp('Obliczone wartości punktu pracy (pierwszy model):');
disp(['Tl_eq = ', num2str(Tl_eq), '°C']);
disp(['Tp_eq = ', num2str(Tp_eq), '°C']);

if abs(Tl_eq - Tl_nominal) < 1e-3 && abs(Tp_eq - Tp_nominal) < 1e-3
    disp('Punkt pracy zgadza się z wartościami nominalnymi (pierwszy model).');
else
    disp('Punkt pracy NIE zgadza się z wartościami nominalnymi (pierwszy model).');
end

%% 4. Wybór jednego przypadku i symulacja pierwszego modelu

czasskok = 1000;       % Czas skoku [s]
czas_symulacji = 10000; % Czas symulacji [s]

% Przypadek: Brak zmiany Tzew, zmiana Pg o 10%
Tzew0 = TzewN;    % Temperatura zew. nominalna
Pg0 = Pgn;        % Moc grzałki nominalna
deltaTzew = 0;    % Brak zmiany temperatury zewnętrznej
delta_Pg = 1.1;   % Zwiększenie mocy grzałki o 10% (1.1 * Pg0)

% Przekazanie zmiennych do workspace
assignin('base', 'Tzew0', Tzew0);
assignin('base', 'deltaTzew', deltaTzew);
assignin('base', 'Pg0', Pg0);
assignin('base', 'delta_Pg', delta_Pg);
assignin('base', 'czasskok', czasskok);

% Ponowne wyliczenie punktu równowagi dla danych wejściowych (choć mogą być takie same)
A = [ (Ksl + Ksw), -Ksw;
      -Ksw,       (Ksp + Ksw) ];
B = [ Pg0 + Ksl * Tzew0;
      Ksp * Tzew0 ];

Temps = A \ B;
Tl_eq = Temps(1);
Tp_eq = Temps(2);

% Symulacja pierwszego modelu
simOut = sim("untitled.slx", 'StopTime', num2str(czas_symulacji));
TP_out_1 = simOut.get('TP_out');
czas_sim_1 = simOut.tout;

% Rysowanie wykresu z pierwszego modelu
figure;
plot(czas_sim_1, TP_out_1, 'b', 'LineWidth', 1.5);
hold on;  % ważne, aby dodać kolejny wykres na ten sam rysunek

xlabel('Czas [s]');
ylabel('Temperatura w prawym pokoju [°C]');
title('Zmiana temperatury w prawym pokoju dla dwóch modeli');
grid on;

% Opis pierwszej krzywej w legendzie
legendEntries = {sprintf('Model 1: Tzew0=%.1f°C, \\DeltaPg=%.1f', Tzew0, delta_Pg)};

%% Czesc 2: Drugi model

% Parametry dodatkowe do drugiego modelu
T = 1855;
k = 3.5/1000;
Tw20 = 15;  % Zmienna wykorzystywana w drugim modelu
T0=1000;
% Przekazanie zmiennych do workspace dla drugiego modelu
assignin('base', 'TzewN', TzewN);
assignin('base', 'Pg0', Pg0);
assignin('base', 'delta_Pg', delta_Pg);
assignin('base', 'czasskok', czasskok);
assignin('base', 'Tw20', Tw20);

% Symulacja drugiego modelu
simOut2 = sim('untitled1.slx', 'StopTime', num2str(czas_symulacji));
czas_sim_2 = simOut2.tout;
TP_out_2 = simOut2.get('TP_out');

% Dodanie drugiej krzywej do tego samego wykresu
plot(czas_sim_2, TP_out_2, 'r', 'LineWidth', 1.5);

% Dodanie opisu drugiej krzywej do legendy
legendEntries{end+1} = sprintf('Model 2: Tzew0=%.1f°C, \\DeltaPg=%.1f, Tw20=%.1f', TzewN, delta_Pg, Tw20);

legend(legendEntries);
hold off;
