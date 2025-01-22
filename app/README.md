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
$ cd ~/scripts
$ ./create_new_projects.sh
```

update the file `vite.config.ts` as follows

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

## ノウハウ

> frontend を更新すると、二回 API が呼ばれる
> @stock.tsx
> どこか、Memo 化、useEffect, useCallback などで無駄な api call を減らせますか？
> 減らせる場合、ここにはどの手法を使うべきですか？
> その理由も知りたい

この状況では、API が 2 回呼ばれる主な原因は、React の開発モードでの厳格モード（Strict Mode）にある可能性が高いです。しかし、実際の運用環境ではこの問題は発生しないはずです。
それでも、API コールを最適化したい場合、以下の方法を提案します：

1. useStockData フックで useCallback を使用する。

2. コンポーネントをメモ化する。
   以下に、これらの最適化を適用した例を示します：

useStockData.ts

```ts
import { useState, useEffect, useCallback } from "react";
import axios from "axios";

// ... (前のコードと同じ)

export const useStockData = () => {
  const [stockData, setStockData] = useState<StockData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchStockData = useCallback(async () => {
    try {
      const response = await axios.get<StockDataResponse>(
        "http://localhost:8000/api/scrape_own_stock_list_and_register_to_db"
      );
      setStockData(response.data.data);
    } catch (error) {
      if (axios.isAxiosError(error)) {
        setError(`データの取得に失敗しました: ${error.message}`);
      } else {
        setError("データの取得に失敗しました");
      }
      console.error("Fetching stock data failed:", error);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchStockData();
  }, [fetchStockData]);

  return { stockData, loading, error };
};
```

stock.tsx

```ts
import React, { memo } from "react";
import Contact from "../components/contact";
import Container from "../components/container";
import Hero from "../components/hero";
import {
  TwoColumn,
  TwoColumnMain,
  TwoColumnSidebar,
} from "../components/two-column";
import StockTable from "../components/stocktable";
import { useStockData } from "../hooks/useStockData";

const Stock = memo(function Stock() {
  const { stockData, loading, error } = useStockData();

  return (
    <Container>
      <Hero title="Stock" subtitle="Stock management" imageOn={false} />
      <TwoColumn>
        <TwoColumnMain>
          {loading ? (
            <p>データを読み込んでいます...</p>
          ) : error ? (
            <p>{error}</p>
          ) : (
            <StockTable data={stockData} />
          )}
        </TwoColumnMain>
        <TwoColumnSidebar>
          <Contact />
        </TwoColumnSidebar>
      </TwoColumn>
    </Container>
  );
});

export default Stock;
```

これらの最適化を使用する理由：

1. useCallback: fetchStockData 関数をメモ化することで、不必要な再作成を防ぎます。これにより、useEffect の依存配列が変更されないため、余分な API コールを防ぐことができます。

2. memo: コンポーネントをメモ化することで、親コンポーネントが再レンダリングされても、このコンポーネントのプロップスが変更されない限り、再レンダリングを防ぐことができます。
   しかし、この場合、これらの最適化は実際にはあまり効果がない可能性があります。なぜなら：

- useStockData フックは既に useEffect を使用しており、コンポーネントのマウント時に 1 回だけ API を呼び出すはずです。
- Stock コンポーネントは最上位のコンポーネントであり、親からのプロップスの変更による不要な再レンダリングはありません。

したがって、この特定の場合、これらの最適化は過剰である可能性があります。API が 2 回呼ばれる問題は、おそらく React の開発モードでの動作によるものであり、実際の運用環境では問題にならないはずです。
代わりに、以下の点を確認することをお勧めします：

1. React の開発モードで Strict Mode が有効になっていないか確認する。
2. ブラウザの開発者ツールでネットワークタブを確認し、実際に 2 回の API コールが行われているか確認する。
3. useStockData フック内で console.log を使用して、フックが実際に 2 回呼び出されているかどうかを確認する。

これらの確認を行った後、実際に問題が存在する場合にのみ、上記の最適化を適用することを検討してください。

> 提案の方法で修正したのですが、二回呼ばれていますね

はい、その通りです。コンソールログから、useStockData フックが 2 回呼び出されていることが確認できました。これは、React の Strict Mode によるものである可能性が高いです。
Strict Mode は開発環境でコンポーネントを意図的に 2 回レンダリングし、副作用の問題を検出するために使用されます。本番環境ではこの動作は発生しません。
しかし、API コールを最適化したい場合は、以下の方法を試すことができます：

1. useRef を使用して、最初の呼び出しのみ API リクエストを行うようにする：

useStockData.ts

```ts
import { useState, useEffect, useRef } from "react";
import axios from "axios";

export const useStockData = () => {
  const [stockData, setStockData] = useState<StockData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const effectRan = useRef(false);

  useEffect(() => {
    if (effectRan.current === false) {
      console.log("useStockData effect running");

      const fetchStockData = async () => {
        console.log("Fetching stock data...");
        try {
          const response = await axios.get<StockDataResponse>(
            "http://localhost:8000/api/scrape_own_stock_list_and_register_to_db"
          );
          console.log("Stock data fetched successfully");
          setStockData(response.data.data);
        } catch (error) {
          console.error("Error fetching stock data:", error);
          if (axios.isAxiosError(error)) {
            setError(`データの取得に失敗しました: ${error.message}`);
          } else {
            setError("データの取得に失敗しました");
          }
        } finally {
          setLoading(false);
        }
      };

      fetchStockData();
    }

    return () => {
      effectRan.current = true;
    };
  }, []);

  return { stockData, loading, error };
};
```

この方法では、useRef を使用して最初の呼び出しのみ API リクエストを行います。これにより、Strict Mode での二重呼び出しを防ぐことができます。

2. もし可能であれば、アプリケーションのルートで Strict Mode を無効にすることも考えられます。ただし、これは推奨されません。Strict Mode は開発中に潜在的な問題を発見するのに役立つためです。

```ts
import React from "react";
import ReactDOM from "react-dom";
import App from "./App";

ReactDOM.render(<App />, document.getElementById("root"));
```

ただし、この二重呼び出しは開発環境でのみ発生し、本番環境では発生しないことを覚えておいてください。したがって、実際のパフォーマンスに影響を与えることはありません。

最後に、API の呼び出しが本当に問題になる場合（例えば、データの変更を引き起こす場合）は、サーバー側でべき等性を確保することも検討してください。これにより、同じリクエストが複数回送信されても安全になります。

> useState ではなくて useRes にするのはなぜでしょう？

申し訳ありません。私の説明に誤りがありました。useState を useRef に完全に置き換えるわけではありません。useRef は useState と併用して使用します。この混乱を招いてしまい、申し訳ありません。
正確には、useRef を追加で使用する理由は以下の通りです：
値の保持: useRef は、その値を変更してもコンポーネントの再レンダリングを引き起こさない特別な変数を作成します。
レンダー間の一貫性: useRef の値はレンダー間で保持されます。つまり、コンポーネントが再レンダリングされても、その値は保持されます。
副作用の制御: 特に useEffect 内で、特定の条件下でのみ実行したいロジックがある場合に有用です。
useState と useRef を併用する正しい例を以下に示します：

useStockData.ts

```ts
import { useState, useEffect, useRef } from "react";
import axios from "axios";

export const useStockData = () => {
  const [stockData, setStockData] = useState<StockData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const effectRan = useRef(false);

  useEffect(() => {
    if (effectRan.current === false) {
      console.log("useStockData effect running");

      const fetchStockData = async () => {
        console.log("Fetching stock data...");
        try {
          const response = await axios.get<StockDataResponse>(
            "http://localhost:8000/api/scrape_own_stock_list_and_register_to_db"
          );
          console.log("Stock data fetched successfully");
          setStockData(response.data.data);
        } catch (error) {
          console.error("Error fetching stock data:", error);
          if (axios.isAxiosError(error)) {
            setError(`データの取得に失敗しました: ${error.message}`);
          } else {
            setError("データの取得に失敗しました");
          }
        } finally {
          setLoading(false);
        }
      };

      fetchStockData();
    }

    return () => {
      effectRan.current = true;
    };
  }, []);

  return { stockData, loading, error };
};
```

この例では：

- useState は依然として stockData, loading, error の状態を管理するために使用されています。

- useRef は effectRan という新しい変数を作成し、エフェクトが既に実行されたかどうかを追跡するために使用されています。

この方法により、Strict Mode での二重呼び出しを防ぎつつ、コンポーネントの状態管理も適切に行うことができます。
