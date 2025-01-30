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



%% Parametry modelu (Część 2)
T = 760;
k = 3.5 / 1000;
Tw20 =15;
%dPg=0.1*Pgn;
Tzero=40;




%% Lab 4

% Parametry skoku i symulacji
czasskok = 500;       % Czas skoku [s]
czas_symulacji = 5000; % Czas symulacji [s]

% Przypadek: Brak zmiany Tzew, zmiana Pg o 20%
Tzew0 = TzewN;    % Temperatura zew. nominalna
Pg0 = Pgn;        % Moc grzałki nominalna
deltaTzew = 0;    % Brak zmiany temperatury zewnętrznej
%delta_Pg = 1.1;

% Ponowne wyliczenie punktu równowagi dla danych wejściowych
A = [ (Ksl + Ksw), -Ksw;
      -Ksw,       (Ksp + Ksw) ];

B = [ Pg0 + Ksl * Tzew0;
      Ksp * Tzew0 ];

Temps = A \ B;
Tl_eq = Temps(1);
Tp_eq = Temps(2);





Kp=0.9*T/(k*Tzero);
Ti=3.33*Tzero;
CV=Pgn;
PV=Tw20;
SP0 = Tp_eq;
dSP = 1;
deltaTzew = 0;

% Symulacja obiektu
%simOut = sim("untitled2.slx", 'StopTime', num2str(czas_symulacji));

% Wyodrębnienie wyników symulacji
%TP_out = simOut.get('TP_out');
%czas_sim = simOut.tout;


%figure;
%plot(czas_sim, TP_out, 'b', 'LineWidth', 1);




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
aPg = simOut.get('aPg');
czas_sim = simOut.tout;

% Rysowanie pierwszego przypadku
figure;
plot(czas_sim, aPg, 'r', 'LineWidth', 1, 'DisplayName', 'dSP=5, \DeltaTzew=0');
hold on;

% Parametry drugiego przypadku
dSP = 0;
deltaTzew = 5;

% Symulacja drugiego przypadku
assignin('base', 'dSP', dSP);
assignin('base', 'deltaTzew', deltaTzew);
simOut = sim("untitled2.slx", 'StopTime', '5000');
aPg = simOut.get('aPg');

% Rysowanie drugiego przypadku
plot(czas_sim, aPg, 'b', 'LineWidth', 1, 'DisplayName', 'dSP=0, \DeltaTzew=5');

% Konfiguracja wykresu
xlabel('Czas [s]');
ylabel('Moc grzałki [°W]');
title('Porównanie przypadków symulacji');
legend('show');
grid on;