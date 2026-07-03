clc, clearvars 

%%Load model

model_path = "DCCONTROL_INDOMAIN.slx";
load_system(model_path);


%% Input parameters

Ra = input('Input the Armature resistance: ');
La = input('Input the Armature inductance: ');
Kb = input('Input the Back EMF constant: ');
Kt = input('Input the Torque constant: ');
J =  input('Input the Rotor inertia: ');
V_supply = input('Input the Voltage Supply: ');
B = input('Input the Rotor rotational friction constant: ');
omega_ref = input('Input the reference speed (rad/s) at which the motor should steady at: ');
ss_threshold = 0.02*omega_ref; 



%% calculating Kp,ki and kd 

% Auto-calculated suggested gains (may need manual refinement)
tau_m = (J * Ra) / (Kt * Kb);
tau_e = La/Ra;
tau_m_baseline = 100; % baseline tested motor

Kp = 3 * (tau_m_baseline / tau_m);
Ki = 2 * (tau_m_baseline / tau_m);
Kd = 0;

disp('Loading the model......')
disp('----------------------------------------------------------------------')
%% running model
%some calculations

T_stall = Kt * V_supply/Ra;
TL_values = linspace(0, T_stall, 7);

omega_noload = V_supply*Kt/(Ra*B + Kb*Kt);
fprintf("============MODEL POTENTIALS======================================= \n")
fprintf("The Maximum Torque produced is: %.4f \n",T_stall);
fprintf("The Maximum Speed (no load) is: %.4f \n",omega_noload);
fprintf("The Mechanical time constant is: %.4f \n",tau_m);
fprintf("The Electrical time constant is: %.4f \n",tau_e);
fprintf("=================SUGGESSTED PID CONTROLLER VALUES===================== \n")
fprintf("The Auto calculated Kp: %.4f \n",Kp);
fprintf("The Auto calculated Ki: %.4f \n",Ki);
fprintf("The Auto calculated Kd: %.4f \n ",Kd);

fprintf("===============RUNNING ANALYSIS================================== \n ")
figure;
for T = TL_values(2:end-1) % gives 5 values strictly between 0 and T_stall
    set_param([bdroot '/Step'], 'FinalValue', num2str(T) )

    simOut = sim('DCCONTROL_INDOMAIN.slx');
    logs = simOut.logsout;
    omega_prac = logs.getElement('omega').Values;
    omega_theory = (V_supply*Kt - T*Ra)/(Ra*B + Kb*Kt);
    omega_pracData = omega_prac.Data;
    omega_pracTime = omega_prac.Time;
    settled = abs(omega_pracData - omega_ref) < ss_threshold;

    % Find last time it left the band, settling time is after that
    settled_idx = find(~settled, 1, 'last');
    if isempty(settled_idx)
        settling_time = 0; % settled immediately
    else
        settling_time = omega_pracTime(settled_idx);
    end
    omega_prac_ss = omega_pracData(end);
    error = abs(omega_prac_ss-omega_theory)/omega_theory * 100;
    hold on 
    plot(omega_pracTime, omega_pracData, 'DisplayName', sprintf('TL = %.4f N.m', T));
    grid on
    
    fprintf("for T = %.4f || Thereotical Speed is %.4f || Actual Speed is %.4f || Error is %.4f \n || Setting time is %.4f \n", T,omega_theory,omega_prac_ss,error, settling_time)
    
end 
fprintf("=================ANALYSIS COMPLETED===================== \n")
fprintf("=================CLOSING THE MODEL======================")
yline(omega_ref, 'r--', 'Reference (0.9 rad/s)', 'LineWidth', 1.5);
hold off
legend
title('Variation of speed with load');
ylabel(' w (rad/s)');
xlabel('time (s)');
