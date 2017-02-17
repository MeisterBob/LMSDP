function [data]=readsvg(filename)
    if (~exist('filename', 'var'))
        filename = 'Projekt/svg/dreieck.svg';
    end
    fid = fopen(filename);
    data=struct();
    tline = fgetl(fid);
    while ischar(tline)
        tline = strtrim(tline);
        tag = regexpi(tline, '<(svg|path) ', 'match');
        if ~isempty(tag)
            switch tag{1}
                case '<svg '
                    disp('- svg');
%                    disp(tline);
                    data.height = regexpi(tline, 'height="\d+', 'match');
                    data.height = str2double(extractAfter(data.height, 'height="'));
                    data.width = regexpi(tline, 'width="\d+', 'match');
                    data.width = str2double(extractAfter(data.width, 'width="'));
                case '<path '
                    disp('- path');
                    disp(tline);
                    disp( extractBefore(extractAfter(tline, 'd="'), '"') );
                otherwise
                    disp(['unbekanntes Tag: ', tag{1}]);
                    disp(tline);
            end
        end

        tline = fgetl(fid);
    end
    
    x = [160, 75, 125, 160];
    y = [20, 90, 160, 20];
    p=plot(x, y);
    xlim([0,200]); xticks([]);
    ylim([0,200]); yticks([]);
    fclose(fid);    
end