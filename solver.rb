#!/usr/bin/env ruby

class Solver
  NUM_COLS     = 9
  NUM_ROWS     = 9
  NUM_CELLS    = NUM_COLS*NUM_ROWS
  NUM_BLK_ROWS = 3
  NUM_BLK_COLS = 3
  
  def self.solve(board_file)
    Solver.new(board_file).solve
  end

  def initialize(board_file)
    @file = board_file
    init_blk_to_cells
  end

  def solve
    read_board
    @cells = solve_cells(deep_copy_cells(@cells), 0)
    print_board
  end

  private

  def solve_cells(cells, cell_idx)
    calc_avail_vals(cells, cell_idx)
    if cell_idx == (NUM_CELLS-1)
      if cells[cell_idx].avail_vals.count == 1
        cells[cell_idx].curr_val = cells[cell_idx].avail_vals.first
        return cells
      else
        return nil
      end
    else
      cells[cell_idx].avail_vals.each do |v|
        cells[cell_idx].curr_val = v
        if solution = solve_cells(deep_copy_cells(cells), cell_idx+1)
          return solution
        end
      end
      return nil
    end
  end

  def calc_avail_vals(cells, cell_idx)
    cells[cell_idx].avail_vals -= (
      row_vals(cells, cell_idx) +
      col_vals(cells, cell_idx) +
      blk_vals(cells, cell_idx)
    )
  end

  def row_vals(cells, cell_idx)
    row = row(cell_idx)
    (0...NUM_ROWS).map do |c|
      idx = row * NUM_COLS + c
      idx != cell_idx ? cells[idx].curr_val : nil
    end.compact
  end

  def col_vals(cells, cell_idx)
    col = col(cell_idx)
    (0...NUM_COLS).map do |r|
      idx = r * NUM_COLS + col
      if cells[idx].nil?
        a = 1
      end
      idx != cell_idx ? cells[idx].curr_val : nil
    end.compact
  end

  def blk_vals(cells, cell_idx)
    @blk_to_cells[blk(cell_idx)].map do |idx|
      idx != cell_idx ? cells[idx].curr_val : nil
    end.compact
  end

  def row(cell_idx)
    cell_idx / NUM_ROWS
  end

  def col(cell_idx)
    cell_idx % NUM_COLS
  end

  def blk(cell_idx)
    row(cell_idx) / NUM_BLK_ROWS * NUM_BLK_COLS + col(cell_idx) / NUM_BLK_COLS
  end
  
  def read_board
    @cells = File.read(@file).split("\n").map do |r|
      r.split(",").map { |e| Cell.new(e == "?" ? nil : e.to_i) }
    end.flatten
  end

  def print_board(cells=@cells)
    if cells
      cells.each_with_index do |c,idx|
        print "|" if (idx+1) % 9 == 1
        print " #{c} |"
        print "\n" if (idx+1) % 9 == 0
      end
    else
      puts "woops... couldn't solve puzzle"
    end
  end

  def init_blk_to_cells
    @blk_to_cells = {}
    (0..80).each do |i|
      blk = blk(i)
      @blk_to_cells[blk] ||= []
      @blk_to_cells[blk] << i
    end
  end

  def deep_copy_cells(cells)
    new_cells = []
    cells.each do |c|
      new_cell = Cell.new(c.curr_val)
      new_cell.avail_vals = c.avail_vals.clone
      new_cells << new_cell
    end
    new_cells
  end
end

class Cell
  attr_accessor :curr_val, :avail_vals
  def initialize(val, avail_vals=nil)
    if val.nil?
      @avail_vals = (1..9).map &:to_i
      @curr_val   = nil
    else
      @avail_vals = [val]
      @curr_val   = val
    end
  end
  
  def to_s
    @curr_val.nil? ? ' ' : @curr_val.to_s
  end
end

if ARGV.count != 1
  puts "pass in board file"
  exit 1
end

Solver.solve(ARGV[0])

