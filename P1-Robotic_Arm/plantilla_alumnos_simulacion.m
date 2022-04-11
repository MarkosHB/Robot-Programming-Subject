%---------------------------------------------------
% AYUDA GENERAL: help Scorbot
% AYUDA FUNCIÓN CONCRETA: help Scorbot.nombrefunción
% GRABAR SÓLO LAS POSICIONES, NO EL OBJETO ROBOT
%---------------------------------------------------


clear;
close all;

s=Scorbot(Scorbot.MODEVREP);
s.home;

%{
teach = 0;
if (~teach)
	load('posiciones_conpieza.mat');
    for i=1:3
        res = s.move(aprox1,1);
        s.changeGripper(1);
       
    end
else
	fprintf('----> Teach the robot where is the location for picking items and press Enter to finish.\n\n');
    % Mover con pendant, y después pulsar Enter en la botonera para
    % almacenar la posición.
    % Tras guardar cada posición, salvar el fichero de posiciones
    % ¡Sólo las posiciones, no el objeto robot!
	p1 = s.pendant();   % situar pieza para asegurarse de cogerla. Guardar x,y pieza
    aprox1 = s.pendant(); % moverse en...
    aprox2 = s.pendant(); % moverse en...
    p2 = s.pendant();   % moverse en...
end
%}

%**************
% START PROGRAM
%**************

fprintf('Press any key to start picking-and-placing.\n');
pause;

% 1. Establecemos los puntos de origen (suministro) y destino (torre)
suministro = load('punto1.mat'); 
torre = load('punto2.mat');
sum_low = s.changePosXYZ(suministro.p1, [suministro.p1.xyz(1), suministro.p1.xyz(2), suministro.p1.xyz(3)-440]);
% save('filename.mat', 'px')

% 2. Estimamos la posicion por encima de los puntos establecidos para poder 
 % desplazar el brazo de manera controlada sin interferir en las piezas
aprox_torre = s.changePosXYZ(torre.p2, [torre.p2.xyz(1), torre.p2.xyz(2), torre.p2.xyz(3)+900]);
aprox_sum = s.changePosXYZ(suministro.p1, [suministro.p1.xyz(1), suministro.p1.xyz(2), suministro.p1.xyz(3)+900]);

% Aprovechamos para establecer las posiciones finales de cada una de las piezas
pieza1 = s.changePosXYZ(aprox_torre, [aprox_torre.xyz(1)+350, aprox_torre.xyz(2), aprox_torre.xyz(3)]);
pieza1_down = s.changePosXYZ(pieza1, [pieza1.xyz(1), pieza1.xyz(2), pieza1.xyz(3)-900]);
pieza2 = s.changePosXYZ(aprox_torre, [aprox_torre.xyz(1)-350, aprox_torre.xyz(2), aprox_torre.xyz(3)]);
pieza2_down = s.changePosXYZ(pieza2, [pieza2.xyz(1), pieza2.xyz(2), pieza2.xyz(3)-900]);

% *********** 
% MOVIMIENTOS
% ***********

% *** Primera Pieza *** %
% Colocamos la pieza en su punto de suministro de manera manual. 1cm = 100u
 % X: -1.5190e-021  // Y: -3.5825e-01  // Z: +3.5000e-02
fprintf('Coloca la pieza1 en la posición de suministro y pulsa cualquier tecla para continuar.\n'); pause;

% Acercamos el brazo a la posicion estimada y abrimos la pinza
s.move(aprox_sum,1); s.changeGripper(1);
% Nos acercamos a la pieza por encima para agarrarlo
s.move(suministro.p1,1); s.changeGripper(0);
% Nos la llevamos a la zona de construcción de la torre
 % Para ello realizamos la translación entre los puntos aproximados
s.move(aprox_sum,1);
s.move(aprox_torre,1);
% Nos desplazamos hasta la posición final de la pieza (leve movimiento)
s.move(pieza1,1);
s.move(pieza1_down,1); s.changeGripper(1);
s.move(pieza1,1); s.changeGripper(0);
% Dejamos el brazo justo encima de la construcción
s.move(aprox_torre,1);

% *** Segunda Pieza *** %
% Colocamos la pieza en su punto de suministro de manera manual
 % X: -1.5190e-021  // Y: -3.5825e-01  // Z: 3.5000e-02
fprintf('Coloca la pieza2 en la posición de suministro y pulsa cualquier tecla para continuar.\n'); pause;

% Acercamos el brazo a la posicion estimada y abrimos la pinza
s.move(aprox_sum,1); s.changeGripper(1);
% Nos acercamos a la pieza por encima para agarrarlo
s.move(suministro.p1,1); s.changeGripper(0);
% Nos la llevamos a la zona de construcción de la torre
 % Para ello realizamos la translación entre los puntos aproximados
s.move(aprox_sum,1);
s.move(aprox_torre,1);
% Nos desplazamos hasta la posición final de la pieza (leve movimiento)
s.move(pieza2,1);
s.move(pieza2_down,1); s.changeGripper(1);
s.move(pieza2,1); s.changeGripper(0);
% Dejamos el brazo justo encima de la construcción
s.move(aprox_torre,1);

% *** Tercera Pieza *** %
% Colocamos la pieza en su punto de suministro de manera manual
 % X: -1.5190e-021  // Y: -3.5825e-01  // Z: +8.4999e-03
 % Rotacion sobre el eje OX: +9.0000e+01 (90 grados)
fprintf('Coloca la pieza3 en la posición de suministro y pulsa cualquier tecla para continuar.\n'); pause;

% Acercamos el brazo a la posicion estimada y abrimos la pinza
s.move(aprox_sum,1); s.changeGripper(1);
% Nos acercamos a la pieza por encima para agarrarlo
s.move(sum_low,1); s.changeGripper(0);
% Nos la llevamos a la zona de construcción de la torre
 % Para ello realizamos la translación entre los puntos aproximados
s.move(aprox_sum,1);
s.move(aprox_torre,1);
s.changeGripper(1);

% Devolvemos al brazo al estado inicial
s.home