import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class GuardMapPositions {

    public static final String ANSI_RESET = "\u001B[0m";
    public static final String ANSI_RED = "\u001B[31m";
    public static final String ANSI_YELLOW = "\u001B[33m";
    private static final int MAP_SIZE = 130;

    public static void main(String[] args) throws InterruptedException {
        String[][] map = readFileToMap(args[0]);
        int[][] visitationMatrix = new int[MAP_SIZE][MAP_SIZE];
        Guard guard = locateGuardInMap(map);

        while (!peekNextMapTile(map, guard).equals("!")) {
            visitationMatrix[guard.getY()][guard.getX()] = 1;
            if (peekNextMapTile(map, guard).equals("#"))
                guard.rotateClockwise();
            guard.moveForward();

            //printMapWithGuard(map, visitationMatrix, guard);
            //Thread.sleep(1000);
        }
        System.out.println(sumVisitedTiles(visitationMatrix) + 1);
    }

    private static void printMapWithGuard(String[][] map,int[][] visitMatrix, Guard guard) {
        String tile;
        for (int y = 0; y < MAP_SIZE; y++) {
            for (int x = 0; x < MAP_SIZE; x++) {
                tile = "";
                if (visitMatrix[y][x] == 1)
                    tile += ANSI_RED;
                if (x == guard.getX() && y == guard.getY())
                    tile += ANSI_YELLOW + "*";
                else
                    tile += map[y][x];
                System.out.print(tile + ANSI_RESET);
            }
            System.out.println("");
        }
        System.out.println("");
    }

    private static int sumVisitedTiles(int[][] matrix) {
        int sum = 0;
        for (int y = 0; y < MAP_SIZE; y++) {
            for (int x = 0; x < MAP_SIZE; x++) {
                if (matrix[y][x] == 1) {
                    sum += 1;
                }
            }
        }
        return sum;
    }

    private static String peekNextMapTile(String[][] map, Guard guard) {
        String tile;
        try {
            tile = map[guard.getY() + guard.getDelta_y()][guard.getX() + guard.getDelta_x()];
        }
        catch (ArrayIndexOutOfBoundsException e) {
            tile = "!";
        }
        return tile;
    }

    private static Guard locateGuardInMap(String[][] map) {
        for (int y = 0; y < MAP_SIZE; y++) {
            for (int x = 0; x < MAP_SIZE; x++) {
                if (((String) map[y][x]).equals("^")) {
                    map[y][x] = ".";
                    return new Guard(x, y);
                }
            }
        }
        return null;
    }

    private static String[][] readFileToMap(String fileName) throws RuntimeException {
        String[][] map = new String[MAP_SIZE][MAP_SIZE];
        try (BufferedReader br = new BufferedReader(new FileReader(fileName))) {
            for (int i = 0; i < MAP_SIZE; i++) {
                map[i] = br.readLine().split("");
            }
        } catch (IOException e) {
            throw new RuntimeException("File not found!", e);
        }
        return map;
    }

    private static class Guard {
        private int x;
        private int y;
        private int delta_x;
        private int delta_y;

        public Guard(int x, int y) {
            this.x = x;
            this.y = y;
            delta_x = 0;
            delta_y = -1;
        }

        public int getX() {
            return x;
        }

        public int getY() {
            return y;
        }

        public int getDelta_x() {
            return delta_x;
        }

        public int getDelta_y() {
            return delta_y;
        }

        public void moveForward() {
            x += delta_x;
            y += delta_y;
        }

        public void rotateClockwise() {
            if (delta_x == 0 && delta_y == -1) {
                // From up to right
                delta_x = 1;
                delta_y = 0;
            }
            else if (delta_x == 1 && delta_y == 0) {
                // From right to down
                delta_x = 0;
                delta_y = 1;
            }
            else if (delta_x == 0 && delta_y == 1) {
                // From down to left
                delta_x = -1;
                delta_y = 0;
            }
            else if (delta_x == -1 && delta_y == 0) {
                // From left to up
                delta_x = 0;
                delta_y = -1;
            }
        }
    }
}