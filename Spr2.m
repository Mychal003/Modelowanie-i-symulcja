clc; clear all; close all;

%% 1. Wyznaczenie parametrów modelu

% Wartości nominalne
TzewN = -20;           % Temperatura zewnętrzna nominalna [°C]
Tl_nominal = 20;       % Nominalna temp. w lewym pokoju [°C]
Tp_nominal = 15;       % Nominalna temp. w prawym pokoju [°C]

a = 2;                 % Współczynnik przenikania ciepła [W/°C]
B = 5;                 % Grubość ściany działowej [m]
Pgn = 10000;           % Nominalna moc grzałki [W]

% Wymiary pokoi
x = (50 / B * 2 + 5) / 3;
y = (x - 5) / 2;

Vp = B * x * 3;        % Objętość prawego pokoju [m^3]
Vl = B * y * 3;        % Objętość lewego pokoju [m^3]

% Parametry powietrza
Cp = 1000;             % Ciepło właściwe powietrza [J/(kg*K)]
rop = 1.2;             % Gęstość powietrza [kg/m^3]

% Pojemności cieplne
Cvp = Cp * rop * Vp;   % Pojemność cieplna prawego pokoju [J/°C]
Cvl = Cp * rop * Vl;   % Pojemność cieplna lewego pokoju [J/°C]

%% 2. Obliczenie przewodności cieplnych

Tzew0 = TzewN;
Pg0 = Pgn;

Ksp = Pgn / (a * (Tl_nominal - TzewN) + (Tp_nominal - TzewN));
Ksl = a * Ksp;
Ksw = Ksp * (Tp_nominal - TzewN) / (Tl_nominal - Tp_nominal); % Przewodność między pokojami

%% 3. Obliczenie punktu pracy (punkt równowagi)

A = [ (Ksl + Ksw), -Ksw;
      -Ksw,        (Ksp + Ksw) ];

B = [ Pg0 + Ksl*Tzew0;
      Ksp*Tzew0 ];

Temps = A \ B;
Tl_eq = Temps(1);
Tp_eq = Temps(2);

%% 4. Sprawdzenie poprawności obliczeń punktu pracy

disp('Obliczone wartości punktu pracy:');
disp(['Tl_eq = ', num2str(Tl_eq), '°C']);
disp(['Tp_eq = ', num2str(Tp_eq), '°C']);

disp('Nominalne wartości:');
disp(['Tl_nominal = ', num2str(Tl_nominal), '°C']);
disp(['Tp_nominal = ', num2str(Tp_nominal), '°C']);

if abs(Tl_eq - Tl_nominal) < 1e-3 && abs(Tp_eq - Tp_nominal) < 1e-3
    disp('Punkt pracy zgadza się z wartościami nominalnymi.');
else
    disp('Punkt pracy nie zgadza się z wartościami nominalnymi.');
end

% Przekazanie wartości punktu równowagi do workspace
assignin('base', 'Tl_eq', Tl_eq);
assignin('base', 'Tp_eq', Tp_eq);

%% 5. Definicja skoku w Pg

deltaTzew = 0;          % Brak skoku temperatury zewnętrznej
delta_Pg = 0.1 * Pgn;   % Skok mocy grzałki o 10% wartości nominalnej
czasskok = 1000;        % Moment skoku [s]
czas_symulacji = 10000; % Czas symulacji [s]

% Przygotowanie sygnałów wejściowych (dla bloczków From Workspace w Simulinku)
czas_sim = (0:1:czas_symulacji)';
Pg_input = Pg0 * ones(size(czas_sim));
Pg_input(czas_sim >= czasskok) = Pg0 + delta_Pg; % Skok mocy grzałki

Tzew_input = Tzew0 * ones(size(czas_sim));  % Stała temperatura zewnętrzna

% Przekazanie zmiennych do przestrzeni roboczej
assignin('base', 'deltaTzew', deltaTzew);
assignin('base', 'delta_Pg', delta_Pg);
assignin('base', 'czasskok', czasskok);
assignin('base', 'czas_sim', czas_sim);
assignin('base', 'Pg_input', Pg_input);
assignin('base', 'Tzew_input', Tzew_input);

%% 6. Uruchomienie symulacji
% Upewnij się, że w modelu Simulinka (untitled):
% - Integratory lub stany temperatur mają Initial condition ustawione na Tl_eq i Tp_eq
% - Wejścia Pg_input i Tzew_input podpięte we właściwe miejsca

simOut = sim('untitled', 'StopTime', num2str(czas_symulacji));

% Wyodrębnienie wyników
TP_out = simOut.get('TP_out'); % Temperatura w prawym pokoju
czas_sim = simOut.tout;

% Sprawdzenie wymiarów danych
disp('Wymiary zmiennych:');
disp(['czas_sim: ', num2str(size(czas_sim))]);
disp(['TP_out: ', num2str(size(TP_out))]);

czas_sim = squeeze(czas_sim);
TP_out = squeeze(TP_out);

%% 7. Rysowanie wykresu
figure;
plot(czas_sim, TP_out, 'b', 'LineWidth', 2);
grid on;
xlabel('Czas [s]');
ylabel('Temperatura w prawym pokoju [°C]');
title('Zmiana temperatury w prawym pokoju po skoku mocy grzałki z warunkami początkowymi równowagi');
