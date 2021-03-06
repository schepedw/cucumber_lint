module CucumberLint
  # A linter for a series of steps (as parsed by Gherkin)
  class StepsLinter < Linter

    def initialize steps:, config:, linted_file:
      super config: config, linted_file: linted_file

      @steps = steps
    end


    def lint
      previous_keyword = nil

      @steps.each do |step|
        current_keyword = step.keyword.strip

        if STEP_TYPES.include?(current_keyword) && current_keyword == previous_keyword
          repeated_keyword step.line, current_keyword
        else
          previous_keyword = current_keyword
        end

        lint_table(step.rows) if step.rows && step.rows.is_a?(Array)
      end
    end


    private

    STEP_TYPES = %w(Given When Then)

    def repeated_keyword line_number, keyword
      return unless @config.no_repeating_keywords.enabled

      add_error(
        fix: -> (line) { line.sub(keyword, 'And') },
        line_number: line_number,
        message: "Use \"And\" instead of repeating \"#{keyword}\""
      )
    end


    def lint_table rows
      linter = TableLinter.new rows: rows, config: @config, linted_file: @linted_file
      linter.lint
    end

  end
end
