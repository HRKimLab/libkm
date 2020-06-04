classdef panel_ext < panel
    methods
        function delete(obj)
%             disp('delete called');
        end
        % get next panel
        function next_p = gnp(p)
            refs.type= '.';
            refs.subs= 'ch';
            out = subsref(p, refs); % p.ch doesn't work
            
            n1 = length(out);
            out = subsref(p(1), refs);
            n2 = length(out);   % p(1).ch doesn't work
            
            refs.type= '()';
            refs.subs= {p.row_idx, p.col_idx};
            
            next_p = subsref(p, refs);
            % assign next panel to UserData
            set(gcf, 'UserData', next_p);

            if p.row_first
                % increase indices
                p.col_idx = p.col_idx + 1;
                
                
                if p.col_idx > p.col_n
                    p.row_idx = p.row_idx + 1;
                    p.col_idx = 1;
                end
            else
                % increase indices
                p.row_idx = p.row_idx + 1;
                
                if p.row_idx > p.row_n
                    p.col_idx = p.col_idx + 1;
                    p.row_idx = 1;
                end
            end
        end
        
        % get next axes
        function ax = gna(p)
            ax = [];
            
            out = p.gnp();
            ax = out.select(); % p(row_idx, col_idx).select() doesn't work            
            set(ax, 'tag', 'plot');
        end
        function haha(obj)
            disp('haha');
        end
        
    end
    
    methods (Hidden = true)
        % wrapper function for field assign operation
        function p_out = subsasgn(p, refs, value)
			p_out = p;
            if strcmp(refs(1).subs, 'row_n')
                p.row_n = value;
            elseif strcmp(refs(1).subs, 'col_n')
                p.col_n = value;
            elseif strcmp(refs(1).subs, 'row_first')
                p.row_first = value;
            else
                subsasgn@panel(p, refs, value);
            end
        end
        
        % wrapper function for method call or indexing operation
        function out = subsref(p, refs)
            if strcmp(refs(1).subs, 'gna')
                out = gna(p);
                return;
            elseif strcmp(refs(1).subs, 'gnp')
                out = gnp(p);
                return;
            elseif strcmp(refs(1).subs, 'row_n')
                out = p.row_n;
                return;
            elseif strcmp(refs(1).subs, 'col_n')
                out = p.col_n;
                return;
            elseif strcmp(refs(1).subs, 'row_first')
                out = p.row_first;
                return;
            end
            
            if nargout
                out = subsref@panel(p, refs);
            else
                subsref@panel(p, refs);
            end
            return;
        end
    end
    properties(Access = public)
        row_idx = 1;
        col_idx = 1;
        row_n
        col_n
        row_first = 1;
    end
end