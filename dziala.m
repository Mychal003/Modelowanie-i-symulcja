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

% Punkt równowagi dla Tl i Tp
Pg0 = Pgn;
Tzew0 = TzewN;

% Ustawienie macierzy równań
A = [ (Ksl + Ksw), -Ksw;
      -Ksw,       (Ksp + Ksw) ];

B = [ Pg0 + Ksl * Tzew0;
      Ksp * Tzew0 ];

% Rozwiązanie układu równań
Temps = A \ B;
Tl_eq = Temps(1);
Tp_eq = Temps(2);

%% 4. Sprawdzenie poprawności obliczeń (punkt pracy = wartości nominalne)

disp('Obliczone wartości punktu pracy:');
disp(['Temperatura w lewym pokoju (Tl_eq) = ', num2str(Tl_eq), '°C']);
disp(['Temperatura w prawym pokoju (Tp_eq) = ', num2str(Tp_eq), '°C']);

disp('Nominalne wartości:');
disp(['Temperatura nominalna w lewym pokoju (Tl_nominal) = ', num2str(Tl_nominal), '°C']);
disp(['Temperatura nominalna w prawym pokoju (Tp_nominal) = ', num2str(Tp_nominal), '°C']);

% Sprawdzenie zgodności
if abs(Tl_eq - Tl_nominal) < 1e-3 && abs(Tp_eq - Tp_nominal) < 1e-3
    disp('Punkt pracy zgadza się z wartościami nominalnymi.');
else
    disp('Punkt pracy NIE zgadza się z wartościami nominalnymi.');
end

%% 3. Definicja przypadków (punktów pracy)
tab_Pg0 = [Pgn, Pgn, Pgn*0.8];  
tab_Tzew0 = [TzewN, TzewN + 10, TzewN];

% Czas skoku i symulacji
czasskok = 1000;       % Czas skoku [s]
czas_symulacji = 50000; % Czas symulacji [s]

% Zdefiniuj figury przed pętlą
fig1 = figure;
hold on; grid on;
fig2 = figure;
hold on; grid on;
legendEntriesTl = cell(1,3);
legendEntriesTp = cell(1,3);

% Skoki
%tab_Tzew1 = [-5, -5, -5];   % Ten sam spadek temperatury zewnętrznej o 5°C dla wszystkich przypadków
%tab_Pg1 = [1, 1, 1];        % Brak zmiany mocy grzałki we wszystkich przypadkach
% Skoki
tab_Tzew1 = [0, 0, 0];      % Brak zmiany temperatury zewnętrznej we wszystkich przypadkach
tab_Pg1 = [0.8, 0.8, 0.8];  % Zmniejszenie mocy grzałki o 20% we wszystkich przypadkach

tab_color = {'r', 'g', 'b'}; 

% Czas skoku i symulacji
czasskok = 500;       % Czas skoku [s]
czas_symulacji = 5000; % Czas symulacji [s]

% Zdefiniuj figury i tablice legend przed pętlą

legendEntriesTl = cell(1,3);
legendEntriesTp = cell(1,3);

for i = 1:3
    Tzew0 = tab_Tzew0(i);
    Pg0 = tab_Pg0(i);

    % Definicja skoków
    deltaTzew = tab_Tzew1(i);
    delta_Pg = tab_Pg1(i);

    % Przekazanie zmiennych do przestrzeni roboczej, działa bez tego
    assignin('base', 'Tzew0', Tzew0);
    assignin('base', 'deltaTzew', deltaTzew);
    assignin('base', 'Pg0', Pg0);
    assignin('base', 'delta_Pg', delta_Pg);
    assignin('base', 'czasskok', czasskok);

    % Ustawienie macierzy równań (używając stałych Ksp, Ksl, Ksw)
    A = [ (Ksl + Ksw), -Ksw;
          -Ksw,       (Ksp + Ksw) ];

    B = [ Pg0 + Ksl * Tzew0;
          Ksp * Tzew0 ];

    % Rozwiązanie układu równań
    Temps = A \ B;
    Tl_eq = Temps(1);
    Tp_eq = Temps(2);

    % Wyświetlenie wyników
    fprintf('Iteracja %d:\n', i);
    fprintf('Temperatura w lewym pokoju (Tl_eq) = %.2f°C\n', Tl_eq);
    fprintf('Temperatura w prawym pokoju (Tp_eq) = %.2f°C\n\n', Tp_eq);

    % Symulacja
    simOut = sim("untitled.slx", 'StopTime', num2str(czas_symulacji));

    % Wyodrębnienie wyników symulacji
    Tl_out = simOut.get('TL_out');
    TP_out = simOut.get('TP_out');
    czas_sim = simOut.tout;

    % Tworzenie opisowych wpisów do legendy
    opis = sprintf('Tzew0=%.1f°C, ΔTzew=%.1f°C, Pg0=%.0fW, ΔPg=%.1f', ...
                   Tzew0, deltaTzew, Pg0, delta_Pg);

    % Wykres dla lewego pokoju
    figure(fig1);
    plot(czas_sim, Tl_out, 'Color', tab_color{i});
    hold on;
    xlabel('Czas [s]');
    ylabel('Temperatura w lewym pokoju [°C]');
    title('Zmiana temperatury w lewym pokoju');
    legendEntriesTl{i} = opis;

    % Wykres dla prawego pokoju
    figure(fig2);
    plot(czas_sim, TP_out, 'Color', tab_color{i});
    hold on;
    xlabel('Czas [s]');
    ylabel('Temperatura w prawym pokoju [°C]');
    title('Zmiana temperatury w prawym pokoju');
    legendEntriesTp{i} = opis;
end

% Dodanie legendy po pętli
figure(fig1);
legend(legendEntriesTl);

figure(fig2);
legend(legendEntriesTp);

