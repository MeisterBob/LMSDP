function [data]=readsvg(filename)
    if (~exist('filename', 'var'))
        filename = 'svg/182316-education/svg/blackboard.svg';
    end
    data=struct();
    data.minX=0;
    data.maxX=0;
    data.minY=0;
    data.maxY=0;
    svg = fileread(filename);
    svg = regexprep(svg, '(\n|\r|\t)', '');
    svg = regexprep(svg, ' +', ' ');
    svg = regexprep(svg, '>[ ]+<', '><');
    svg = strsplit(svg, '><');

    data_count = 0;
%     data.path{data_count}{1}=[];
%     data.path{data_count}{2}=[];
    data.path=[,];
    last=[0,0];
    start=[0,0];
    t = linspace(0,1,50);

    for i=1:numel(svg)
        tag = regexpi(svg{i}, '(svg|path) ', 'match');
        if ~isempty(tag)
            switch tag{1}
                case 'svg '
%                     disp('- svg');
                    data.height = regexpi(svg{i}, 'height="\d+', 'match');
                    data.height = str2double(extractAfter(data.height, 'height="'));
                    data.width = regexpi(svg{i}, 'width="\d+', 'match');
                    data.width = str2double(extractAfter(data.width, 'width="'));
                case 'path '
%                     disp('- path');
                    d = extractBefore(extractAfter(svg{i}, 'd="'), '"');
                    d = regexpi(d, '(?<tag>[a-zA-Z]{1})(?<data>[^a-zA-Z]{0,})', 'tokens');
                    for j=1:numel(d)
%                         disp(['tag:', d{j}{1}, ', data:', d{j}{2}]);
                        switch upper(d{j}{1})
                            case 'M'  % move
                                new = regexpi(d{j}{2}, '[,| ]', 'split');
%                                 disp([d{j}{1}, ': ', d{j}{2}, ' -> ', new{1}, ' : ', new{2}]);
                                new{1} = str2double(new{1});
                                new{2} = str2double(new{2});
                                if isstrprop(d{j}{1}, 'lower')
                                     new{1} = last{1} + new{1};
                                     new{2} = last{2} + new{2};
                                end
                                data_count = data_count + 1;
                                data.path{data_count}{1}=[];
                                data.path{data_count}{2}=[];
                                start = new;
                                last = new;
                                data.path{data_count}{1}=[data.path{data_count}{1}, new{1}];
                                data.path{data_count}{2}=[data.path{data_count}{2}, new{2}];
                            case 'L'  % line
                                new = regexpi(d{j}{2}, '-?\d+\.{0,1}\d{0,3}', 'match');
%                                 disp([d{j}{1}, d{j}{2}, new]);
                                new{1} = str2double(new{1});
                                new{2} = str2double(new{2});
                                if isstrprop(d{j}{1}, 'lower')
                                     new{1} = last{1} + new{1};
                                     new{2} = last{2} + new{2};
                                end
                                last = new;
                                data.path{data_count}{1}=[data.path{data_count}{1}, new{1}];
                                data.path{data_count}{2}=[data.path{data_count}{2}, new{2}];
                            case 'V'  % vertical line
                                new = str2double(d{j}{2});
%                                 disp([d{j}{1}, d{j}{2}, new]);
                                if isstrprop(d{j}{1}, 'lower')
                                     new = last{2} + new;
                                end
                                last{2} = new;
                                data.path{data_count}{1}=[data.path{data_count}{1}, last{1}];
                                data.path{data_count}{2}=[data.path{data_count}{2}, new];
                            case 'H'  % horizontal line
%                                 disp([d{j}{1}, d{j}{2}]);
                                new = str2double(d{j}{2});
                                if isstrprop(d{j}{1}, 'lower')
                                     new = last{1} + new;
                                end
                                last{1} = new;
                                data.path{data_count}{1}=[data.path{data_count}{1}, new];
                                data.path{data_count}{2}=[data.path{data_count}{2}, last{2}];
                            case 'C'  % curve
                                new = regexpi(d{j}{2}, '-?\d+\.{0,1}\d{0,3}', 'match');
%                                 disp([d{j}{1}, d{j}{2}, new]);
                                new = str2double(new);
                                if isstrprop(d{j}{1}, 'lower')
                                     new(1) = last{1} + new(1);
                                     new(2) = last{2} + new(2);
                                     new(3) = last{1} + new(3);
                                     new(4) = last{2} + new(4);
                                     new(5) = last{1} + new(5);
                                     new(6) = last{2} + new(6);
                                end
                                pts = kron((1-t).^3,[last{1};last{2}]) + ...
                                      kron(3*(1-t).^2.*t,[new(1);new(2)]) + ...
                                      kron(3*(1-t).*t.^2,[new(3);new(4)]) + ...
                                      kron(t.^3,[new(5);new(6)]);
                                last{1} = new(5);
                                last{2} = new(6);
                                for k=1:2:100
                                    data.path{data_count}{1}=[data.path{data_count}{1}, pts(k)];
                                    data.path{data_count}{2}=[data.path{data_count}{2}, pts(k+1)];
% plot(data.path{data_count}{1}, -1 .* data.path{data_count}{2}); drawnow; pause(0.2);
                                end
%                                 data.path{data_count}{1}=[data.path{data_count}{1}, new{5}];
%                                 data.path{data_count}{2}=[data.path{data_count}{2}, new{6}];
                            case 'S'  % spline
                                new = regexpi(d{j}{2}, '-?\d+\.{0,1}\d{0,3}', 'match');
%                                 disp([d{j}{1}, new]);
                                new = str2double(new);
                                if isstrprop(d{j}{1}, 'lower')
                                     new(1) = last{1} + new(1);
                                     new(2) = last{2} + new(2);
                                     new(3) = last{1} + new(3);
                                     new(4) = last{2} + new(4);
%                                      new{numel(new)-1} = last{1} + new{numel(new)-1};
%                                      new{numel(new)} = last{2} + new{numel(new)};
                                end
                                
                                pts = kron((1-t).^2,   [last{1};last{2}]) + ...
                                      kron(2*(1-t).*t, [new(1);new(2)]) + ...
                                      kron(t.^2,       [new(3);new(4)]);
                                last{1} = new(numel(new)-1);
                                last{2} = new(numel(new));
                                
                                for k=1:2:100
                                    data.path{data_count}{1}=[data.path{data_count}{1}, pts(k)];
                                    data.path{data_count}{2}=[data.path{data_count}{2}, pts(k+1)];
% plot(data.path{data_count}{1}, -1 .* data.path{data_count}{2}); drawnow;
                                end
%                                 data.path{data_count}{1}=[data.path{data_count}{1}, new{numel(new)-1}];
%                                 data.path{data_count}{2}=[data.path{data_count}{2}, new{numel(new)}];
                            case 'Z'  % close path
%                                 disp('Z');
                                data.path{data_count}{1}=[data.path{data_count}{1}, start{1}];
                                data.path{data_count}{2}=[data.path{data_count}{2}, start{2}];
                            otherwise  % unknown tag
%                                 if isstrprop(d{j}{1}, 'upper')
%                                     disp([d{j}{1}, ' upper'])
%                                 else
%                                     disp([d{j}{1}, ' lower'])
%                                 end
                        end
                    end % for j (alle path Elemente)
                otherwise
                    if tag{1,1}=='/'
                        disp('closing tag');
                    else
                        disp(['unbekanntes Tag: ', tag{1}]);
                        disp(svg{i});
                    end
            end
        end
    end

%     close all;
    hold off;
    for i=1:data_count
        plot(data.path{i}{1}, -1 .* data.path{i}{2});
        data.minX = min([data.minX, min(data.path{i}{1})]);
        data.maxX = max([data.maxX, max(data.path{i}{1})]);
        data.minY = min([data.minY, min(data.path{i}{2})]);
        data.maxY = max([data.maxY, max(data.path{i}{2})]);
    hold on;
    end
    axis equal;
    xticks=[];
    yticks=[];
    hold off;
end