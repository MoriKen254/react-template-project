## 新規プロジェクト作成

https://shinke1987.net/?p=1123

### プロジェクト名の変更

- プロジェクト名を置換する。

  - `react_template` でグローバル検索をして、任意のプロジェクト名に置換する。

### Docker コンテナの起動

- まず Windows の コマンドプロンプトで、Node.js 用の Docker イメージを作成する。

```bash
> cd app/docker-config/launcher/prep
> build_prep.bat
```

- 引き続き Windows の コマンドプロンプトで、Node.js 用の Docker コンテナを起動する。

```bash
> cd app/docker-config/launcher/prep
> up_prep.bat
```

- そして Windows の コマンドプロンプトから、Node.js 用の Docker コンテナに入る。

```bash
> cd app/docker-config/launcher/prep
> exec_prep.bat
```

### 新規プロジェクトの作成

- Docker コンテナに入ったら、新規プロジェクトを作成する。

```bash
$ cd ~/Project/scripts
$ ./create_new_projects.sh
```

- すると、`app/src/<project_name>` にスケルトンができあがる。

- `vite.config.ts` を以下のように修正する。

```ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: "0.0.0.0",
    port: 3000,
    watch: {
      usePolling: true,
      interval: 1000,
    },
  },
});
```

### ファイルの整理

以下のファイルを削除する。

- src/assets/react.svg
- src/App.css

以下のファイルのコードの中身を削除する。（ファイルは残す。）

- src/index.css
- src/App.tsx

### 実行

```bash
$ npm run dev
```
