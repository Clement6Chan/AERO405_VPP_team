% Characteristics of the 2x2 ft wind tunnel
% density: kg/m^3
% velocity: m/s
function output_num = tunnel_info(mode_option, varargin)
    if nargin > 1 && isnumeric(varargin{1}) && floor(varargin{1}) == varargin{1}
        input_arg = varargin{1};
    else
        input_arg = 0;
    end
    
    switch mode_option
        case 'density'
            output_num = 1.16954;
            return
        case 'velocity'
            switch input_arg
                case 10
                    output_num = 5.835;
                case 12
                    output_num = 7.294;
                case 14
                    output_num = 8.380;
                case 16
                    output_num = 9.807;
                case 18
                    output_num = 11.243;
                case 20
                    output_num = 12.549;
                case 22
                    output_num = 13.855;
                case 24
                    output_num = 15.188;
                case 26
                    output_num = 16.478;
                case 28
                    output_num = 17.687;
                case 30
                    output_num = 18.840;
            end
            return;
    end
end




