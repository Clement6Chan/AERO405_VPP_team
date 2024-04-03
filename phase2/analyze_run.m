function result = analyze_run(a,r) %angle_idx, run_idx
    rho = 1.17; % kg/m^3
    D = 13*0.0254; % in to m
    A = pi * (D/2)^2;

    table_in = readtable(sprintf("phase2_data/%d_%d.csv",a,r), 'VariableNamingRule', 'preserve');
    arr_in = table2array(table_in);
    Uarr_in = table2array(readtable("phase2_data/PropTestingSpeeds.csv", 'VariableNamingRule', 'preserve'));
    U = Uarr_in(r, 2*a-1) * 0.3048; % fps to m/s
    drag_arr_in = table2array(readtable("phase2_data/DragMeasurement.csv", 'VariableNamingRule', 'preserve'));
    stand_drag = interp1(drag_arr_in(:,2), drag_arr_in(:,4), U);
    
    Q = arr_in(:,9);
    T = arr_in(:,10) + stand_drag;
    rps = arr_in(:,13) ./ 60; % RPM to rps
    V = rps .* (2*pi); % rps to rad/s 
    Pe = arr_in(:,15); % W
    Pm = arr_in(:,16); % W
    effM = arr_in(:,17); % 
    effP = arr_in(:,18) * 9.80665; % kgf/W to N/W
    effO = arr_in(:,19) * 9.80665; % kgf/W to N/W
    Pm_calc = Q .* V; % W
    Pp_calc = T * U; % W
    effM_calc = Pm_calc ./ Pe;

    effP_calc = 2 ./ (1 + (T ./(A*U^2*rho/2) + 1).^(0.5));

    kT = T ./ (rho*rps.^2*D^4);
    kQ = Q ./ (rho*rps.^2*D^5);
    J = U./(rps*D);
    effP_calc2 = kT.*J ./ (2*pi.*kQ);

    effP_calc3 = Pp_calc./Pm_calc;


    result.Q = mean(Q);
    result.T = mean(T);
    result.rps = mean(rps);
    result.V = mean(V);
    result.Pe = mean(Pe);
    result.Pm = mean(Pm);
    result.effM = mean(effM);
    result.effP = mean(effP);
    result.effO = mean(effO);
    result.Pm_calc = mean(Pm_calc);
    result.Pp_calc = mean(Pp_calc);
    result.effM_calc = mean(effM_calc);
    result.effP_calc = mean(effP_calc);
    result.effP_calc2 = mean(effP_calc2);
    result.effP_calc3 = mean(effP_calc3);
    result.J = mean(J);
    result.U = U;
    result.kT = mean(kT);
    result.kQ = mean(kQ);
end

