% Default Stan parameters and validators. Should only contain
% parameters that are valid inputs to Stan cmd-line!
% validator can be
% 1) function handle
% 2) 1x2 cell array of cells, input to validateattributes first element is classes,
% second is attributes
% 3) cell array of strings representing valid arguments

function [params,valid] = stan_params(ver)
if nargin
   if (ver{1}>=2) && (ver{2}>=1) % Stan 2.1+
      adapt_params = struct(...
         'engaged',true,...
         'gamma',0.05,...
         'delta',0.65,...
         'kappa',0.75,...
         't0',10,...
         'init_buffer',75,...
         'term_buffer',50,...
         'window',25);
      adapt_valid = struct(...
         'engaged',{{{'logical'} {'scalar'}}},...
         'gamma',{{{'numeric'} {'scalar','>',0}}},...
         'delta',{{{'numeric'} {'scalar','>',0}}},...
         'kappa',{{{'numeric'} {'scalar','>',0}}},...
         't0',{{{'numeric'} {'scalar','>',0}}},...
         'init_buffer',{{{'numeric'} {'scalar'}}},...
         'term_buffer',{{{'numeric'} {'scalar'}}},...
         'window',{{{'numeric'} {'scalar'}}});
   else
      adapt_params = struct(...
         'engaged',true,...
         'gamma',0.05,...
         'delta',0.65,...
         'kappa',0.75,...
         't0',10);
      adapt_valid = struct(...
         'engaged',{{{'logical'} {'scalar'}}},...
         'gamma',{{{'numeric'} {'scalar','>',0}}},...
         'delta',{{{'numeric'} {'scalar','>',0}}},...
         'kappa',{{{'numeric'} {'scalar','>',0}}},...
         't0',{{{'numeric'} {'scalar','>',0}}});
   end
end
   % Stan 2.0.1
   params.sample = struct(...
                         'num_samples',1000,...
                         'num_warmup',1000,...
                         'save_warmup',false,...
                         'thin',1,...
                         'adapt',adapt_params,...
                         'algorithm','hmc',...
                         'hmc',struct(...
                                      'engine','nuts',...
                                      'static',struct('int_time',2*pi),...
                                      'nuts',struct('max_depth',10),...
                                      'metric','diag_e',...
                                      'stepsize',1,...
                                      'stepsize_jitter',0));
   valid.sample = struct(...
                         'num_samples',{{{'numeric'} {'scalar','>=',0}}},...
                         'num_warmup',{{{'numeric'} {'scalar','>=',0}}},...
                         'save_warmup',{{{'logical'} {'scalar'}}},...
                         'thin',{{{'numeric'} {'scalar','>',0}}},...
                         'adapt',adapt_valid,...
                         'algorithm',{{'hmc'}},...
                         'hmc',struct(...
                                      'engine',{{'static' 'nuts'}},...
                                      'static',struct('int_time',{{{'numeric'} {'scalar','>',0}}}),...
                                      'nuts',struct('max_depth',{{{'numeric'} {'scalar','>',0}}}),...
                                      'metric',{{'unit_e' 'diag_e' 'dense_e'}},...
                                      'stepsize',1,...
                                      'stepsize_jitter',0));

   params.optimize = struct(...
                           'algorithm','bfgs',...
                           'nesterov',struct(...
                                             'stepsize',1),...
                           'bfgs',struct(...
                                         'init_alpha',0.001,...
                                         'tol_obj',1e-8,...
                                         'tol_grad',1e-8,...
                                         'tol_param',1e-8),...
                           'iter',2000,...
                           'save_iterations',false);

   valid.optimize = struct(...
                           'algorithm',{{'nesterov' 'bfgs' 'newton'}},...
                           'nesterov',struct(...
                                             'stepsize',{{{'numeric'} {'scalar','>',0}}}),...
                           'bfgs',struct(...
                                         'init_alpha',{{{'numeric'} {'scalar','>',0}}},...
                                         'tol_obj',{{{'numeric'} {'scalar','>',0}}},...
                                         'tol_grad',{{{'numeric'} {'scalar','>',0}}},...
                                         'tol_param',{{{'numeric'} {'scalar','>',0}}}),...
                           'iter',{{{'numeric'} {'scalar','>',0}}},...
                           'save_iterations',{{{'logical'} {'scalar'}}});

   params.diagnose = struct(...
                           'test','gradient');
   valid.diagnose = struct(...
                           'test',{{{'gradient'}}});

   params.id = 1; % 0 doesnot work as default
   valid.id = {{'numeric'} {'scalar','>',0}};
   params.data = struct('file','');
   valid.data = struct('file',@isstr);
   params.init = 2;
   valid.init = {{'numeric' 'char'} {'nonempty'}}; % shitty validator
   params.random = struct('seed',-1);
   valid.random = struct('seed',{{{'numeric'} {'scalar'}}});

   params.output = struct(...
                          'file','output.csv',...
                          'append_sample',false,...
                          'diagnostic_file','',...
                          'append_diagnostic',false,...
                          'refresh',100);
   valid.output = struct(...
                          'file',@isstr,...
                          'append_sample',{{{'logical'} {'scalar'}}},...
                          'diagnostic_file',@isstr,...
                          'append_diagnostic',{{{'logical'} {'scalar'}}},...
                          'refresh',{{{'numeric'} {'scalar','>',0}}});
end
